import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import 'messenger_registration.dart';

/// Public Messenger registration API.
///
/// Flutter should use this endpoint instead of orchestrating Email IDP and
/// MessengerUser creation separately.
class MessengerRegistrationEndpoint extends Endpoint {
  static const _registration = MessengerRegistration();

  /// Starts registration for [email] and [username].
  Future<UuidValue> start(
    Session session, {
    required String email,
    required String username,
  }) {
    return _registration.start(
      session,
      email: email,
      username: username,
    );
  }

  /// Verifies the email code and returns a registration token.
  Future<String> verify(
    Session session, {
    required UuidValue accountRequestId,
    required String verificationCode,
  }) {
    return _registration.verify(
      session,
      accountRequestId: accountRequestId,
      verificationCode: verificationCode,
    );
  }

  /// Completes registration and returns an authenticated session.
  Future<AuthSuccess> finish(
    Session session, {
    required String registrationToken,
    required String password,
  }) {
    return _registration.finish(
      session,
      registrationToken: registrationToken,
      password: password,
    );
  }
}
