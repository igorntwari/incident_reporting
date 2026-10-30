import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../auth/domain/app_user.dart';
import '../domain/incident.dart';
import '../domain/incident_enums.dart';

/// Form input shared by create and edit, so both paths validate and persist
/// the same fields.
class IncidentDraft {
  const IncidentDraft({
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.photo,
  });

  final String title;
  final String description;
  final IncidentCategory category;
  final String location;

  /// A newly picked photo. `null` keeps whatever photo the report already has.
  final File? photo;

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'category': category.name,
        'location': location,
      };
}

/// All Firestore + Storage access for incidents.
class IncidentRepository {
  IncidentRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _incidents =>
      _firestore.collection(FirebasePaths.incidents);

  // ---------------------------------------------------------------- read

  Stream<List<Incident>> watchAll() => _incidents
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(_toIncidents);

  /// Equality-only query (no orderBy) so no composite index is required;
  /// results are sorted client-side instead.
  Stream<List<Incident>> watchByReporter(String uid) => _incidents
      .where('reporterId', isEqualTo: uid)
      .snapshots()
      .map((snap) => _toIncidents(snap)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));

  Stream<Incident?> watchById(String id) => _incidents
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? Incident.fromFirestore(doc) : null);

  List<Incident> _toIncidents(QuerySnapshot<Map<String, dynamic>> snap) =>
      snap.docs.map(Incident.fromFirestore).toList();

  // --------------------------------------------------------------- write

  /// The photo is uploaded first so a report never exists pointing at a
  /// missing file. The doc id is generated up-front to name the photo.
  Future<void> create(IncidentDraft draft, AppUser reporter) =>
      guardFirebase(() async {
        final doc = _incidents.doc();
        final photo = draft.photo == null
            ? null
            : await _uploadPhoto(reporter.uid, doc.id, draft.photo!);

        await doc.set({
          ...draft.toMap(),
          'status': IncidentStatus.submitted.name,
          'reporterId': reporter.uid,
          'reporterName': reporter.fullName,
          'photoUrl': photo?.url,
          'photoPath': photo?.path,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'history': [
            StatusChange(
              status: IncidentStatus.submitted,
              changedAt: DateTime.now(),
              changedBy: reporter.fullName,
            ).toMap(),
          ],
        });
      });

  Future<void> update(Incident incident, IncidentDraft draft) =>
      guardFirebase(() async {
        final photo = draft.photo == null
            ? null
            : await _uploadPhoto(incident.reporterId, incident.id, draft.photo!);

        await _incidents.doc(incident.id).update({
          ...draft.toMap(),
          if (photo != null) 'photoUrl': photo.url,
          if (photo != null) 'photoPath': photo.path,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

  /// Staff-only (enforced by security rules). Appends to the audit trail.
  Future<void> updateStatus({
    required String incidentId,
    required IncidentStatus status,
    required AppUser staff,
    String? note,
  }) =>
      guardFirebase(() {
        final change = StatusChange(
          status: status,
          changedAt: DateTime.now(),
          changedBy: staff.fullName,
          note: note?.trim(),
        );
        return _incidents.doc(incidentId).update({
          'status': status.name,
          'updatedAt': FieldValue.serverTimestamp(),
          'history': FieldValue.arrayUnion([change.toMap()]),
        });
      });

  Future<void> delete(Incident incident) => guardFirebase(() async {
        await _incidents.doc(incident.id).delete();
        if (incident.photoPath != null) {
          // Best-effort: an orphaned photo must not fail the delete.
          await _storage
              .ref(incident.photoPath)
              .delete()
              .catchError((Object _) {});
        }
      });

  Future<({String url, String path})> _uploadPhoto(
    String uid,
    String incidentId,
    File file,
  ) async {
    final path = '${FirebasePaths.incidentPhotos}/$uid/$incidentId.jpg';
    final ref = _storage.ref(path);
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return (url: await ref.getDownloadURL(), path: path);
  }
}
