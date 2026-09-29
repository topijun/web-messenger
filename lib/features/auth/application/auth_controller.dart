import 'package:flutter/foundation.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/core/errors/auth_error_mapper.dart';
import 'package:mobile_messenger/features/auth/data/auth_repository.dart';
import 'package:mobile_messenger/features/auth/domain/auth_state.dart';

/// Owns Messenger authentication state and talks to Serverpod Auth.
///
/// Presentation widgets should depend on this controller, not on the client.
class AuthController extends ChangeNotifier {
  /// Creates an [AuthController].
  AuthController({
    required AuthRepository repository,
    required AuthSession session,
  }) : _repository = repository,
       _session = session;

  final AuthRepository _repository;
  final AuthSession _session;

  AuthState _state = const AuthState.checking();
  UuidValue? _accountRequestId;
  String? _pendingPassword;

  /// Current authentication snapshot.
  AuthState get state => _state;

  /// Restores any stored Serverpod session on startup.
  Future<void> restoreSession() async {
    _setState(const AuthState.checking());
    try {
      await _session.initialize();
      if (_session.isAuthenticated) {
        await _enterAuthenticated();
      } else {
        _setState(const AuthState.unauthenticated());
      }
    } catch (_) {
      if (_session.isAuthenticated) {
        await _enterAuthenticated();
      } else {
        _setState(
          const AuthState.unauthenticated(
            errorMessage: 'Could not restore the previous session.',
          ),
        );
      }
    }
  }

  /// Logs in with official Email IDP and stores the Serverpod session.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setBusy();
    try {
      final authSuccess = await _repository.login(
        email: email.trim(),
        password: password,
      );
      await _session.applyAuthSuccess(authSuccess);
      await _enterAuthenticated();
    } catch (error) {
      _setState(
        AuthState(
          status: AuthStatus.error,
          errorMessage: AuthErrorMapper.login(error),
        ),
      );
    }
  }

  /// Starts Messenger registration and keeps [password] only in memory.
  Future<bool> startRegistration({
    required String email,
    required String username,
    required String password,
  }) async {
    _setBusy();
    _discardPassword();
    try {
      final accountRequestId = await _repository.startRegistration(
        email: email.trim(),
        username: username.trim(),
      );
      _accountRequestId = accountRequestId;
      _pendingPassword = password;
      _setState(
        AuthState(
          status: AuthStatus.awaitingVerification,
          pendingEmail: email.trim(),
          pendingUsername: username.trim(),
        ),
      );
      return true;
    } catch (error) {
      _discardPassword();
      _setState(
        AuthState(
          status: AuthStatus.error,
          errorMessage: AuthErrorMapper.registrationStart(error),
        ),
      );
      return false;
    }
  }

  /// Verifies the email code and finishes registration with the stored password.
  Future<bool> verifyRegistration({required String verificationCode}) async {
    final accountRequestId = _accountRequestId;
    final password = _pendingPassword;
    if (accountRequestId == null || password == null) {
      _setState(
        const AuthState.unauthenticated(
          errorMessage: AuthErrorMapper.verificationFailedMessage,
        ),
      );
      return false;
    }

    _setBusy();
    try {
      final registrationToken = await _repository.verifyRegistration(
        accountRequestId: accountRequestId,
        verificationCode: verificationCode.trim(),
      );
      final authSuccess = await _repository.finishRegistration(
        registrationToken: registrationToken,
        password: password,
      );
      _discardPassword();
      _accountRequestId = null;
      await _session.applyAuthSuccess(authSuccess);
      await _enterAuthenticated();
      return true;
    } catch (error) {
      _setState(
        AuthState(
          status: AuthStatus.awaitingVerification,
          pendingEmail: _state.pendingEmail,
          pendingUsername: _state.pendingUsername,
          errorMessage: AuthErrorMapper.registrationAfterStart(error),
        ),
      );
      return false;
    }
  }

  /// Requests another verification code for the pending registration.
  Future<bool> resendRegistrationCode() async {
    final email = _state.pendingEmail;
    final username = _state.pendingUsername;
    final password = _pendingPassword;
    if (email == null || username == null || password == null) {
      _setState(
        const AuthState.unauthenticated(
          errorMessage: AuthErrorMapper.verificationFailedMessage,
        ),
      );
      return false;
    }

    return startRegistration(
      email: email,
      username: username,
      password: password,
    );
  }

  /// Drops in-progress registration and the held password.
  void cancelRegistration() {
    _accountRequestId = null;
    _discardPassword();
    _setState(const AuthState.unauthenticated());
  }

  /// Starts official Email IDP password recovery.
  Future<UuidValue?> startPasswordReset({required String email}) async {
    _setBusy(keepStatus: true);
    try {
      final requestId = await _repository.startPasswordReset(
        email: email.trim(),
      );
      _setState(_state.copyWith(isBusy: false, clearError: true));
      return requestId;
    } catch (error) {
      _setState(
        _state.copyWith(
          isBusy: false,
          errorMessage: AuthErrorMapper.passwordResetStart(error),
        ),
      );
      return null;
    }
  }

  /// Verifies the password-reset email code.
  Future<String?> verifyPasswordReset({
    required UuidValue passwordResetRequestId,
    required String verificationCode,
  }) async {
    _setBusy(keepStatus: true);
    try {
      final token = await _repository.verifyPasswordReset(
        passwordResetRequestId: passwordResetRequestId,
        verificationCode: verificationCode.trim(),
      );
      _setState(_state.copyWith(isBusy: false, clearError: true));
      return token;
    } catch (error) {
      _setState(
        _state.copyWith(
          isBusy: false,
          errorMessage: AuthErrorMapper.passwordResetAfterStart(error),
        ),
      );
      return null;
    }
  }

  /// Completes password recovery, then logs in with the new password.
  Future<bool> finishPasswordReset({
    required String finishPasswordResetToken,
    required String email,
    required String newPassword,
  }) async {
    _setBusy(keepStatus: true);
    try {
      await _repository.finishPasswordReset(
        finishPasswordResetToken: finishPasswordResetToken,
        newPassword: newPassword,
      );
      _setState(_state.copyWith(isBusy: false, clearError: true));
      await login(email: email, password: newPassword);
      return _state.isAuthenticated;
    } catch (error) {
      _setState(
        _state.copyWith(
          isBusy: false,
          errorMessage: AuthErrorMapper.passwordResetAfterStart(error),
        ),
      );
      return false;
    }
  }

  /// Drops authenticated UI if the stored session is no longer valid.
  ///
  /// Temporary network failures do not sign the user out.
  Future<void> reconcileSession() async {
    if (!_state.isAuthenticated) {
      return;
    }
    try {
      await _session.initialize();
    } catch (_) {
      // Keep the current UI when the backend is only temporarily unreachable.
    }
    if (!_session.isAuthenticated) {
      _discardPassword();
      _accountRequestId = null;
      _setState(const AuthState.unauthenticated());
    }
  }

  /// Signs out of the current Serverpod session.
  Future<void> logout() async {
    _discardPassword();
    _accountRequestId = null;
    _setBusy(keepStatus: true);
    try {
      await _session.signOut();
    } finally {
      _setState(const AuthState.unauthenticated());
    }
  }

  @override
  void dispose() {
    _discardPassword();
    super.dispose();
  }

  Future<void> _enterAuthenticated() async {
    String? username;
    try {
      username = (await _repository.getCurrentMessengerUser())?.username;
    } catch (_) {
      username = null;
    }
    _setState(
      AuthState(
        status: AuthStatus.authenticated,
        username: username,
      ),
    );
  }

  void _setBusy({bool keepStatus = false}) {
    if (keepStatus) {
      _setState(_state.copyWith(isBusy: true, clearError: true));
    } else {
      _setState(
        _state.copyWith(
          status: _state.status == AuthStatus.checking
              ? AuthStatus.unauthenticated
              : _state.status,
          isBusy: true,
          clearError: true,
        ),
      );
    }
  }

  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }

  void _discardPassword() {
    _pendingPassword = null;
  }

  /// Exposed for tests: whether a registration password is still held.
  @visibleForTesting
  bool get hasPendingPassword => _pendingPassword != null;
}
