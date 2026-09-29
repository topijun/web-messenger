import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_messenger/core/validation/auth_validators.dart';

void main() {
  group('AuthValidators.usernameError', () {
    test('accepts valid usernames from the assignment examples', () {
      for (final username in ['topi', 'Topi123', 'topi_j', 'topi.juntunen']) {
        expect(AuthValidators.usernameError(username), isNull);
      }
    });

    test('rejects too short, too long, spaces, and other special characters', () {
      expect(AuthValidators.usernameError('to'), isNotNull);
      expect(AuthValidators.usernameError('a' * 31), isNotNull);
      expect(AuthValidators.usernameError('topi juntunen'), isNotNull);
      expect(AuthValidators.usernameError('topi@juntunen'), isNotNull);
    });
  });

  group('PasswordStrength', () {
    test('accepts a password that meets every assignment rule', () {
      expect(PasswordStrength.from('Password1!').isValid, isTrue);
      expect(AuthValidators.passwordError('Password1!'), isNull);
    });

    test('rejects passwords missing a required rule', () {
      expect(PasswordStrength.from('Pass1!').hasMinLength, isFalse);
      expect(PasswordStrength.from('PASSWORD1!').hasLowercase, isFalse);
      expect(PasswordStrength.from('password1!').hasUppercase, isFalse);
      expect(PasswordStrength.from('Password!').hasDigit, isFalse);
      expect(PasswordStrength.from('Password1').hasSpecial, isFalse);
      expect(AuthValidators.passwordError('password'), isNotNull);
    });
  });

  group('AuthValidators.passwordConfirmationError', () {
    test('requires a matching confirmation', () {
      expect(
        AuthValidators.passwordConfirmationError('Password1!', ''),
        isNotNull,
      );
      expect(
        AuthValidators.passwordConfirmationError('Password1!', 'Password1!!'),
        isNotNull,
      );
      expect(
        AuthValidators.passwordConfirmationError('Password1!', 'Password1!'),
        isNull,
      );
    });
  });
}
