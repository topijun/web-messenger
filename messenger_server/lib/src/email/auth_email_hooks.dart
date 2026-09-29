import 'package:serverpod/serverpod.dart';

import 'auth_email_sender.dart';
import 'auth_email_service.dart';

/// Email IDP send callbacks. Keep these wrappers thin.
class AuthEmailHooks {
  /// Creates [AuthEmailHooks] around [emails].
  AuthEmailHooks(this._emails, {this.devMode = false});

  final AuthEmailService _emails;

  /// When true, also logs the raw Email IDP codes to the server console.
  final bool devMode;

  /// Official Email IDP registration verification callback.
  Future<void> sendRegistrationVerificationCode(
    Session session, {
    required String email,
    required UuidValue accountRequestId,
    required String verificationCode,
    required Transaction? transaction,
  }) async {
    if (devMode) {
      _sendRegistrationCode(
        session,
        email: email,
        accountRequestId: accountRequestId,
        verificationCode: verificationCode,
        transaction: transaction,
      );
    }
    await _deliver(
      session,
      successLog: '[EmailIdp] Registration verification email sent',
      failureLog: '[EmailIdp] Registration verification email failed',
      send: () => _emails.sendRegistrationVerification(
        email: email,
        verificationCode: verificationCode,
      ),
    );
  }

  /// Official Email IDP password-reset callback.
  ///
  /// Email IDP only invokes this when an account exists, so unknown emails
  /// never reach SMTP.
  Future<void> sendPasswordResetVerificationCode(
    Session session, {
    required String email,
    required UuidValue passwordResetRequestId,
    required String verificationCode,
    required Transaction? transaction,
  }) async {
    if (devMode) {
      _sendPasswordResetCode(
        session,
        email: email,
        passwordResetRequestId: passwordResetRequestId,
        verificationCode: verificationCode,
        transaction: transaction,
      );
    }
    await _deliver(
      session,
      successLog: '[EmailIdp] Password reset email sent',
      failureLog: '[EmailIdp] Password reset email failed',
      send: () => _emails.sendPasswordReset(
        email: email,
        verificationCode: verificationCode,
      ),
    );
  }

  Future<void> _deliver(
    Session session, {
    required String successLog,
    required String failureLog,
    required Future<void> Function() send,
  }) async {
    try {
      await send();
      session.log(successLog);
    } catch (error, stackTrace) {
      final safeError = error is AuthEmailDeliveryException
          ? error
          : const AuthEmailDeliveryException();
      session.log(
        failureLog,
        level: LogLevel.error,
        exception: safeError,
        stackTrace: stackTrace,
      );
      throw safeError;
    }
  }

  void _sendRegistrationCode(
    Session session, {
    required String email,
    required UuidValue accountRequestId,
    required String verificationCode,
    required Transaction? transaction,
  }) {
    session.log('[EmailIdp] Registration code ($email): $verificationCode');
  }

  void _sendPasswordResetCode(
    Session session, {
    required String email,
    required UuidValue passwordResetRequestId,
    required String verificationCode,
    required Transaction? transaction,
  }) {
    session.log('[EmailIdp] Password reset code ($email): $verificationCode');
  }
}
