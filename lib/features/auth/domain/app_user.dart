import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  student,
  staff;

  static UserRole fromName(String? name) =>
      values.firstWhere((r) => r.name == name, orElse: () => student);

  String get label => switch (this) {
        student => 'Student',
        staff => 'Staff',
      };
}

/// Profile stored at `users/{uid}`. Identity lives in Firebase Auth;
/// this document adds the app-specific data (name, role).
class AppUser {
  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.createdAt,
  });

  final String uid;
  final String fullName;
  final String email;
  final UserRole role;
  final DateTime? createdAt;

  bool get isStaff => role == UserRole.staff;

  String get firstName => fullName.split(' ').first;

  String get initials => fullName
      .split(' ')
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return AppUser(
      uid: doc.id,
      fullName: data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: UserRole.fromName(data['role'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// New accounts are always students; staff are promoted by an admin.
  /// Firestore rules reject any attempt to self-assign `staff`.
  Map<String, dynamic> toNewUserMap() => {
        'fullName': fullName,
        'email': email,
        'role': UserRole.student.name,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
