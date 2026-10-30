import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incident_reporting/features/auth/domain/app_user.dart';

void main() {
  test('new users are always created as students', () {
    const user = AppUser(
      uid: 'u1',
      fullName: 'Amina Hassan',
      email: 'a.hassan@alustudent.com',
      role: UserRole.staff, // even if a caller tries to pass staff
    );
    final map = user.toNewUserMap();
    expect(map['role'], 'student');
    expect(map['createdAt'], isA<FieldValue>());
  });

  test('derives display helpers from the full name', () {
    const user = AppUser(
      uid: 'u1',
      fullName: 'Amina Hassan',
      email: 'a@alustudent.com',
      role: UserRole.student,
    );
    expect(user.firstName, 'Amina');
    expect(user.initials, 'AH');
    expect(user.isStaff, isFalse);
  });

  test('reads role from Firestore, defaulting unknown values to student',
      () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.doc('users/s1').set({
      'fullName': 'John Staff',
      'email': 'j@alueducation.com',
      'role': 'staff',
    });
    await firestore.doc('users/x1').set({'fullName': 'X Y', 'role': 'admin'});

    expect(AppUser.fromFirestore(await firestore.doc('users/s1').get()).isStaff,
        isTrue);
    expect(AppUser.fromFirestore(await firestore.doc('users/x1').get()).role,
        UserRole.student);
  });
}
