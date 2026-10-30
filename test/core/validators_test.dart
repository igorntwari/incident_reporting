import 'package:flutter_test/flutter_test.dart';
import 'package:incident_reporting/core/utils/formatters.dart';
import 'package:incident_reporting/core/utils/validators.dart';

void main() {
  group('Validators.aluEmail', () {
    test('accepts student and staff ALU domains', () {
      expect(Validators.aluEmail('a.hassan@alustudent.com'), isNull);
      expect(Validators.aluEmail('j.doe@alueducation.com'), isNull);
      expect(Validators.aluEmail('  A.Hassan@ALUSTUDENT.com '), isNull);
    });

    test('rejects other domains and malformed input', () {
      expect(Validators.aluEmail('someone@gmail.com'), contains('ALU email'));
      expect(Validators.aluEmail('not-an-email'), isNotNull);
      expect(Validators.aluEmail(''), 'Email is required');
    });
  });

  group('Validators.password', () {
    test('requires length, letters and digits', () {
      expect(Validators.password('short1'), contains('at least'));
      expect(Validators.password('onlyletters'), contains('letters and numbers'));
      expect(Validators.password('campus2026'), isNull);
    });

    test('confirmPassword compares against the original', () {
      final validator = Validators.confirmPassword(() => 'campus2026');
      expect(validator('campus2026'), isNull);
      expect(validator('different1'), 'Passwords do not match');
    });
  });

  test('fullName requires first and last name', () {
    expect(Validators.fullName('Amina'), isNotNull);
    expect(Validators.fullName('Amina Hassan'), isNull);
  });

  test('description enforces a minimum length', () {
    expect(Validators.description('Too short'), isNotNull);
    expect(Validators.description('No water on the 2nd floor since 8am'), isNull);
  });

  group('Formatters.timeAgo', () {
    final now = DateTime(2026, 10, 30, 12);
    test('uses relative wording for recent dates', () {
      expect(Formatters.timeAgo(now, now: now), 'Just now');
      expect(Formatters.timeAgo(now.subtract(const Duration(hours: 2)), now: now),
          '2 hours ago');
      expect(Formatters.timeAgo(now.subtract(const Duration(days: 1)), now: now),
          '1 day ago');
    });

    test('falls back to an absolute date after a week', () {
      expect(Formatters.timeAgo(DateTime(2026, 10, 1), now: now), 'Oct 1, 2026');
    });
  });
}
