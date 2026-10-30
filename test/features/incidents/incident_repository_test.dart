import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incident_reporting/core/config/app_config.dart';
import 'package:incident_reporting/features/auth/domain/app_user.dart';
import 'package:incident_reporting/features/incidents/data/incident_repository.dart';
import 'package:incident_reporting/features/incidents/domain/incident_enums.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FirebaseStorage {}

void main() {
  late FakeFirebaseFirestore firestore;
  late IncidentRepository repo;

  const student = AppUser(
    uid: 'student-1',
    fullName: 'Amina Hassan',
    email: 'a.hassan@alustudent.com',
    role: UserRole.student,
  );
  const staff = AppUser(
    uid: 'staff-1',
    fullName: 'John Staff',
    email: 'j.staff@alueducation.com',
    role: UserRole.staff,
  );
  const draft = IncidentDraft(
    title: 'Water shortage',
    description: 'No water on the 2nd floor since this morning.',
    category: IncidentCategory.water,
    location: 'Student Residence',
  );

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = IncidentRepository(firestore, _MockStorage());
  });

  test('create persists a submitted report with an initial history entry',
      () async {
    await repo.create(draft, student);

    final incidents = await repo.watchByReporter(student.uid).first;
    final incident = incidents.single;
    expect(incident.title, draft.title);
    expect(incident.category, IncidentCategory.water);
    expect(incident.status, IncidentStatus.submitted);
    expect(incident.reporterName, student.fullName);
    expect(incident.hasPhoto, isFalse);
    expect(incident.history.single.status, IncidentStatus.submitted);
  });

  test('updateStatus changes status and appends to the audit trail', () async {
    await repo.create(draft, student);
    final created = (await repo.watchAll().first).single;

    await repo.updateStatus(
      incidentId: created.id,
      status: IncidentStatus.inProgress,
      staff: staff,
      note: 'Plumber assigned',
    );

    final updated = await repo.watchById(created.id).first;
    expect(updated!.status, IncidentStatus.inProgress);
    expect(updated.history, hasLength(2));
    expect(updated.history.last.changedBy, staff.fullName);
    expect(updated.history.last.note, 'Plumber assigned');
    expect(updated.changeFor(IncidentStatus.inProgress), isNotNull);
  });

  test('update edits content without touching status', () async {
    await repo.create(draft, student);
    final created = (await repo.watchAll().first).single;

    await repo.update(
      created,
      const IncidentDraft(
        title: 'Water shortage (Block C)',
        description: 'Still no water on the 2nd floor, getting worse.',
        category: IncidentCategory.water,
        location: 'Block C',
      ),
    );

    final updated = await repo.watchById(created.id).first;
    expect(updated!.location, 'Block C');
    expect(updated.status, IncidentStatus.submitted);
  });

  test('watchByReporter only returns that user\'s reports', () async {
    await repo.create(draft, student);
    await repo.create(draft, staff);

    expect(await repo.watchByReporter(student.uid).first, hasLength(1));
    expect(await repo.watchAll().first, hasLength(2));
  });

  test('delete removes the report', () async {
    await repo.create(draft, student);
    final created = (await repo.watchAll().first).single;

    await repo.delete(created);

    expect(await repo.watchById(created.id).first, isNull);
    final raw = await firestore.collection(FirebasePaths.incidents).get();
    expect(raw.docs, isEmpty);
  });
}
