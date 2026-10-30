import '../config/app_config.dart';

/// Form validators. Each returns an error message, or `null` when valid,
/// matching Flutter's `FormFieldValidator` contract.
abstract final class Validators {
  static final _emailPattern = RegExp(r'^[^@\s]+@([^@\s]+)$');

  static String? required(String? value, [String field = 'This field']) =>
      (value == null || value.trim().isEmpty) ? '$field is required' : null;

  static String? fullName(String? value) {
    final error = required(value, 'Full name');
    if (error != null) return error;
    return value!.trim().contains(' ') ? null : 'Enter your first and last name';
  }

  static String? aluEmail(String? value) {
    final error = required(value, 'Email');
    if (error != null) return error;
    final match = _emailPattern.firstMatch(value!.trim().toLowerCase());
    if (match == null) return 'Enter a valid email address';
    return AppConfig.allowedEmailDomains.contains(match.group(1))
        ? null
        : 'Use your ALU email (@${AppConfig.allowedEmailDomains.join(' or @')})';
  }

  static String? password(String? value) {
    final error = required(value, 'Password');
    if (error != null) return error;
    if (value!.length < AppConfig.minPasswordLength) {
      return 'Use at least ${AppConfig.minPasswordLength} characters';
    }
    final hasLetter = value.contains(RegExp('[A-Za-z]'));
    final hasDigit = value.contains(RegExp('[0-9]'));
    return hasLetter && hasDigit ? null : 'Include both letters and numbers';
  }

  static String? Function(String?) confirmPassword(String Function() original) =>
      (value) => value == original() ? null : 'Passwords do not match';

  static String? title(String? value) {
    final error = required(value, 'Title');
    if (error != null) return error;
    return value!.trim().length < 5 ? 'Title is too short' : null;
  }

  static String? description(String? value) {
    final error = required(value, 'Description');
    if (error != null) return error;
    return value!.trim().length < AppConfig.descriptionMinLength
        ? 'Add a bit more detail (at least '
            '${AppConfig.descriptionMinLength} characters)'
        : null;
  }
}
