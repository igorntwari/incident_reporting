import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/action_controller.dart';
import '../../../core/providers/firebase_providers.dart';
import '../data/auth_repository.dart';
import '../domain/app_user.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  ),
);

/// Firebase session. Drives router redirects.
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

/// The signed-in user's profile (name + role), live from Firestore.
/// Promoting a user to staff in the console updates the app instantly.
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final uid = ref.watch(authStateProvider.select((s) => s.value?.uid));
  if (uid == null) return Stream.value(null);
  return ref.watch(authRepositoryProvider).watchProfile(uid);
});

final isStaffProvider = Provider<bool>(
  (ref) => ref.watch(currentUserProvider).value?.isStaff ?? false,
);

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

class AuthController extends ActionController {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<bool> signIn(String email, String password) =>
      run(() => _repo.signIn(email: email, password: password));

  Future<bool> register(String fullName, String email, String password) =>
      run(() => _repo.register(
            fullName: fullName,
            email: email,
            password: password,
          ));

  Future<bool> sendPasswordReset(String email) =>
      run(() => _repo.sendPasswordReset(email));

  Future<bool> resendVerificationEmail() =>
      run(_repo.resendVerificationEmail);

  /// Returns `true` only if the email is now verified.
  Future<bool> checkEmailVerified() async {
    var verified = false;
    await run(() async => verified = await _repo.refreshEmailVerified());
    return verified;
  }

  Future<void> signOut() => run(_repo.signOut);
}
