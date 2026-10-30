import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// The only exception type the presentation layer needs to understand.
class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Runs a Firebase call and converts any failure into an [AppException]
/// with a user-friendly message. Used by every repository.
Future<T> guardFirebase<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on AppException {
    rethrow;
  } on FirebaseAuthException catch (e) {
    throw AppException(_authMessage(e.code));
  } on FirebaseException catch (e) {
    throw AppException(_firebaseMessage(e.code));
  } catch (_) {
    throw const AppException('Something went wrong. Please try again.');
  }
}

String _authMessage(String code) => switch (code) {
      'invalid-email' => 'That email address is not valid.',
      'user-disabled' => 'This account has been disabled.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' =>
        'Incorrect email or password.',
      'email-already-in-use' => 'An account already exists for that email.',
      'weak-password' => 'Please choose a stronger password.',
      'too-many-requests' => 'Too many attempts. Please wait and try again.',
      'network-request-failed' => 'No internet connection.',
      _ => 'Authentication failed. Please try again.',
    };

String _firebaseMessage(String code) => switch (code) {
      'permission-denied' ||
      'unauthorized' =>
        'You do not have permission to do that.',
      'unavailable' => 'Service unavailable. Check your connection.',
      'not-found' || 'object-not-found' => 'That item no longer exists.',
      _ => 'Something went wrong. Please try again.',
    };
