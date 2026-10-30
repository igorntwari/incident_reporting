import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/app_user.dart';

/// Wraps Firebase Auth plus the `users/{uid}` profile document.
/// Firebase exceptions are translated to [AppException] so the UI only ever
/// deals with human-readable messages.
class AuthRepository {
  AuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirebasePaths.users);

  /// Emits on sign-in, sign-out and token refresh (e.g. after verification).
  Stream<User?> authStateChanges() => _auth.idTokenChanges();

  User? get currentUser => _auth.currentUser;

  Stream<AppUser?> watchProfile(String uid) => _users
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? AppUser.fromFirestore(doc) : null);

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) =>
      guardFirebase(() async {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = credential.user!;
        await user.updateDisplayName(fullName);
        await _users.doc(user.uid).set(
              AppUser(
                uid: user.uid,
                fullName: fullName,
                email: email,
                role: UserRole.student,
              ).toNewUserMap(),
            );
        await user.sendEmailVerification();
      });

  Future<void> signIn({required String email, required String password}) =>
      guardFirebase(
        () => _auth.signInWithEmailAndPassword(email: email, password: password),
      );

  Future<void> sendPasswordReset(String email) =>
      guardFirebase(() => _auth.sendPasswordResetEmail(email: email));

  Future<void> resendVerificationEmail() =>
      guardFirebase(() => _auth.currentUser!.sendEmailVerification());

  /// Reloads the user and forces a fresh ID token so the `email_verified`
  /// claim seen by security rules is up to date. Returns the new state.
  Future<bool> refreshEmailVerified() => guardFirebase(() async {
        final user = _auth.currentUser!;
        await user.reload();
        final refreshed = _auth.currentUser!;
        if (refreshed.emailVerified) await refreshed.getIdToken(true);
        return refreshed.emailVerified;
      });

  Future<void> signOut() => _auth.signOut();
}
