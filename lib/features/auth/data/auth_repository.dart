import 'package:messenger_client/messenger_client.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';

/// Server-backed authentication operations used by the Flutter auth flow.
abstract class AuthRepository {
  /// Logs in with official Email IDP credentials.
  Future<AuthSuccess> login({
    required String email,
    required String password,
  });

  /// Starts Messenger registration. Must call `messengerRegistration` only.
  Future<UuidValue> startRegistration({
    required String email,
    required String username,
  });

  /// Verifies the registration email code.
  Future<String> verifyRegistration({
    required UuidValue accountRequestId,
    required String verificationCode,
  });

  /// Completes Messenger registration with the collected password.
  Future<AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  });

  /// Starts official Email IDP password recovery.
  Future<UuidValue> startPasswordReset({required String email});

  /// Verifies the password-reset email code.
  Future<String> verifyPasswordReset({
    required UuidValue passwordResetRequestId,
    required String verificationCode,
  });

  /// Completes official Email IDP password recovery.
  Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  });

  /// Loads the signed-in Messenger user, if one exists.
  Future<MessengerUser?> getCurrentMessengerUser();
}

/// [AuthRepository] that talks to the generated Serverpod client.
class ServerpodAuthRepository implements AuthRepository {
  /// Creates a [ServerpodAuthRepository].
  const ServerpodAuthRepository(this._client);

  final Client _client;

  @override
  Future<AuthSuccess> login({
    required String email,
    required String password,
  }) {
    return _client.emailIdp.login(email: email, password: password);
  }

  @override
  Future<UuidValue> startRegistration({
    required String email,
    required String username,
  }) {
    return _client.messengerRegistration.start(
      email: email,
      username: username,
    );
  }

  @override
  Future<String> verifyRegistration({
    required UuidValue accountRequestId,
    required String verificationCode,
  }) {
    return _client.messengerRegistration.verify(
      accountRequestId: accountRequestId,
      verificationCode: verificationCode,
    );
  }

  @override
  Future<AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) {
    return _client.messengerRegistration.finish(
      registrationToken: registrationToken,
      password: password,
    );
  }

  @override
  Future<UuidValue> startPasswordReset({required String email}) {
    return _client.emailIdp.startPasswordReset(email: email);
  }

  @override
  Future<String> verifyPasswordReset({
    required UuidValue passwordResetRequestId,
    required String verificationCode,
  }) {
    return _client.emailIdp.verifyPasswordResetCode(
      passwordResetRequestId: passwordResetRequestId,
      verificationCode: verificationCode,
    );
  }

  @override
  Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) {
    return _client.emailIdp.finishPasswordReset(
      finishPasswordResetToken: finishPasswordResetToken,
      newPassword: newPassword,
    );
  }

  @override
  Future<MessengerUser?> getCurrentMessengerUser() {
    return _client.messengerUser.get();
  }
}

/// Persists and clears the official Serverpod client session.
abstract class AuthSession {
  /// Whether a session is currently stored on the client.
  bool get isAuthenticated;

  /// Restores a stored session and validates it when possible.
  Future<void> initialize();

  /// Stores [authSuccess] using the official Serverpod session manager.
  Future<void> applyAuthSuccess(AuthSuccess authSuccess);

  /// Signs out of the current device and clears local session state.
  Future<void> signOut();
}

/// [AuthSession] backed by [FlutterAuthSessionManager].
class ServerpodAuthSession implements AuthSession {
  /// Creates a [ServerpodAuthSession].
  ServerpodAuthSession(this._client);

  final Client _client;

  @override
  bool get isAuthenticated => _client.auth.isAuthenticated;

  @override
  Future<void> initialize() async {
    await _client.auth.initialize();
  }

  @override
  Future<void> applyAuthSuccess(AuthSuccess authSuccess) {
    return _client.auth.updateSignedInUser(authSuccess);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOutDevice();
  }
}
