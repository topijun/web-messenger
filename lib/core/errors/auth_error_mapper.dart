import 'package:messenger_client/messenger_client.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';

/// Maps protocol and network failures to copy that is safe to show in the UI.
class AuthErrorMapper {
  /// Generic copy for any failure after registration [start].
  static const verificationFailedMessage =
      'Verification could not be completed. Please check the code and try again.';

  /// Shown when registration cannot be started, without saying why.
  static const registrationCouldNotStartMessage =
      'Registration could not be started.\n'
      'Please check your email address and username and try again.';

  /// Maps a login failure.
  static String login(Object error) {
    if (error is EmailAccountLoginException) {
      return switch (error.reason) {
        EmailAccountLoginExceptionReason.invalidCredentials =>
          'Invalid email or password. Please check your details and try again.',
        EmailAccountLoginExceptionReason.tooManyAttempts =>
          'Too many failed login attempts. Please try again later.',
        EmailAccountLoginExceptionReason.unknown =>
          'Login could not be completed. Please try again.',
      };
    }
    return _connectionOrUnexpected(error);
  }

  /// Maps a failure from registration [start] only.
  ///
  /// Does not mention whether the email is already registered.
  static String registrationStart(Object error) {
    if (error is MessengerUsernameTakenException) {
      return 'That username is already taken. Please choose another.';
    }
    if (error is MessengerInvalidUsernameException) {
      return 'That username is not allowed. Use 3–30 letters, numbers, '
          'underscore, or period.';
    }
    if (error is MessengerInvalidRegistrationInputException) {
      if (error.field == 'email') {
        return 'Enter a valid email address.';
      }
      return 'Please check your details and try again.';
    }
    if (error is MessengerRegistrationIncompleteException) {
      return registrationCouldNotStartMessage;
    }
    return _connectionOrUnexpected(error);
  }

  /// Maps a failure from registration [verify] or [finish].
  static String registrationAfterStart(Object error) {
    if (error is EmailAccountRequestException &&
        error.reason == EmailAccountRequestExceptionReason.policyViolation) {
      return 'Password does not meet the strength requirements.';
    }
    if (error is MessengerInvalidRegistrationInputException &&
        error.field == 'password') {
      return 'Password does not meet the strength requirements.';
    }
    return verificationFailedMessage;
  }

  /// Maps a password-reset [start] failure without revealing account existence.
  static String passwordResetStart(Object error) {
    if (error is EmailAccountPasswordResetException &&
        error.reason ==
            EmailAccountPasswordResetExceptionReason.tooManyAttempts) {
      return 'Too many password reset attempts. Please try again later.';
    }
    return _connectionOrUnexpected(error);
  }

  /// Maps a password-reset [verify] or [finish] failure.
  static String passwordResetAfterStart(Object error) {
    if (error is EmailAccountPasswordResetException) {
      return switch (error.reason) {
        EmailAccountPasswordResetExceptionReason.policyViolation =>
          'Password does not meet the strength requirements.',
        EmailAccountPasswordResetExceptionReason.tooManyAttempts =>
          'Too many password reset attempts. Please try again later.',
        EmailAccountPasswordResetExceptionReason.expired ||
        EmailAccountPasswordResetExceptionReason.invalid ||
        EmailAccountPasswordResetExceptionReason.unknown =>
          verificationFailedMessage,
      };
    }
    return verificationFailedMessage;
  }

  static String _connectionOrUnexpected(Object error) {
    if (error is ServerpodClientException) {
      return 'A connection error occurred. Please check your internet '
          'connection and try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
