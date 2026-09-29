import 'auth_email_sender.dart';

/// Builds registration and password-reset messages for Email IDP callbacks.
class AuthEmailService {
  /// Creates an [AuthEmailService].
  const AuthEmailService(this._sender);

  final AuthEmailSender _sender;

  /// Sends the Email IDP registration verification code to [email].
  Future<void> sendRegistrationVerification({
    required String email,
    required String verificationCode,
  }) {
    return _sender.send(
      AuthEmailMessage(
        recipient: email,
        subject: 'Your Messenger verification code',
        body: _registrationBody(verificationCode),
      ),
    );
  }

  /// Sends the Email IDP password-reset verification code to [email].
  Future<void> sendPasswordReset({
    required String email,
    required String verificationCode,
  }) {
    return _sender.send(
      AuthEmailMessage(
        recipient: email,
        subject: 'Your Messenger password reset code',
        body: _passwordResetBody(verificationCode),
      ),
    );
  }

  static String _registrationBody(String verificationCode) {
    return 'This is your Messenger account verification code.\n'
        '\n'
        '$verificationCode\n'
        '\n'
        'Enter this code in the Messenger app to finish creating your account.\n'
        '\n'
        'If you did not request this, you can ignore this email.\n';
  }

  static String _passwordResetBody(String verificationCode) {
    return 'This is your Messenger password reset code.\n'
        '\n'
        '$verificationCode\n'
        '\n'
        'Enter this code in the Messenger app to choose a new password.\n'
        '\n'
        'If you did not request a password reset, you can ignore this email.\n';
  }
}
