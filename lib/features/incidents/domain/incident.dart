import 'package:cloud_firestore/cloud_firestore.dart';

import 'incident_enums.dart';

/// One entry in an incident's audit trail, rendered as the status timeline.
class StatusChange {
  const StatusChange({
    required this.status,
    required this.changedAt,
    required this.changedBy,
    this.note,
  });

  final IncidentStatus status;
  final DateTime changedAt;
  final String changedBy;
  final String? note;

  factory StatusChange.fromMap(Map<String, dynamic> map) => StatusChange(
        status: IncidentStatus.fromName(map['status'] as String?),
        changedAt: (map['changedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        changedBy: map['changedBy'] as String? ?? '',
        note: map['note'] as String?,
      );

  // Arrays cannot hold FieldValue.serverTimestamp(), so a client timestamp
  // is used for history entries.
  Map<String, dynamic> toMap() => {
        'status': status.name,
        'changedAt': Timestamp.fromDate(changedAt),
        'changedBy': changedBy,
        if (note != null && note!.isNotEmpty) 'note': note,
      };
}

class Incident {
  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.reporterId,
    required this.reporterName,
    required this.createdAt,
    required this.updatedAt,
    this.photoUrl,
    this.photoPath,
    this.history = const [],
  });

  final String id;
  final String title;
  final String description;
  final IncidentCategory category;
  final String location;
  final IncidentStatus status;
  final String reporterId;
  final String reporterName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? photoUrl;

  /// Storage path of the photo, kept so the file can be deleted with the report.
  final String? photoPath;
  final List<StatusChange> history;

  bool get hasPhoto => photoUrl != null;

  /// Reporters may edit or withdraw a report only until staff pick it up.
  bool get isEditableByReporter => status == IncidentStatus.submitted;

  /// The most recent change into [target], if the report ever reached it.
  StatusChange? changeFor(IncidentStatus target) =>
      history.lastWhereOrNull((change) => change.status == target);

  factory Incident.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    // A just-written serverTimestamp is null in the local snapshot until the
    // server confirms it; fall back to "now" so new reports render at once.
    final createdAt =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    return Incident(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: IncidentCategory.fromName(data['category'] as String?),
      location: data['location'] as String? ?? '',
      status: IncidentStatus.fromName(data['status'] as String?),
      reporterId: data['reporterId'] as String? ?? '',
      reporterName: data['reporterName'] as String? ?? '',
      createdAt: createdAt,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? createdAt,
      photoUrl: data['photoUrl'] as String?,
      photoPath: data['photoPath'] as String?,
      history: (data['history'] as List<dynamic>? ?? const [])
          .map((e) => StatusChange.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

extension<T> on List<T> {
  T? lastWhereOrNull(bool Function(T) test) {
    for (var i = length - 1; i >= 0; i--) {
      if (test(this[i])) return this[i];
    }
    return null;
  }
}
