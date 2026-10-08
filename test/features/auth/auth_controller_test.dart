import 'package:flutter_test/flutter_test.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/core/errors/auth_error_mapper.dart';
import 'package:mobile_messenger/features/auth/application/auth_controller.dart';
import 'package:mobile_messenger/features/auth/domain/auth_state.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';

import '../../support/auth_fakes.dart';

void main() {
  test('restoreSession with no stored session is unauthenticated', () async {
    final auth = AuthController(
      repository: FakeAuthRepository(),
      session: FakeAuthSession(),
    );

    await auth.restoreSession();

    expect(auth.state.status, AuthStatus.unauthenticated);
    expect(auth.state.isAuthenticated, isFalse);
  });

  test('restoreSession with a stored session goes to Home username', () async {
    final auth = AuthController(
      repository: FakeAuthRepository(currentUser: testMessengerUser()),
      session: FakeAuthSession(authenticated: true),
    );

    await auth.restoreSession();

    expect(auth.state.status, AuthStatus.authenticated);
    expect(auth.state.username, 'Topi.J');
  });

  test('login failure is an authentication error', () async {
    final auth = AuthController(
      repository: FakeAuthRepository(
        loginError: EmailAccountLoginException(
          reason: EmailAccountLoginExceptionReason.invalidCredentials,
        ),
      ),
      session: FakeAuthSession(),
    );

    await auth.login(email: 'user@example.com', password: 'Password1!');

    expect(auth.state.status, AuthStatus.error);
    expect(auth.state.errorMessage, contains('Invalid email or password'));
    expect(auth.state.isAuthenticated, isFalse);
  });

  test('login success becomes authenticated', () async {
    final session = FakeAuthSession();
    final auth = AuthController(
      repository: FakeAuthRepository(currentUser: testMessengerUser()),
      session: session,
    );

    await auth.login(email: 'user@example.com', password: 'Password1!');

    expect(session.authenticated, isTrue);
    expect(auth.state.status, AuthStatus.authenticated);
    expect(auth.state.username, 'Topi.J');
  });

  test('startRegistration holds the password and awaits verification', () async {
    final auth = AuthController(
      repository: FakeAuthRepository(),
      session: FakeAuthSession(),
    );

    final started = await auth.startRegistration(
      email: 'topi@example.com',
      username: 'Topi.J',
      password: 'Password1!',
    );

    expect(started, isTrue);
    expect(auth.state.status, AuthStatus.awaitingVerification);
    expect(auth.state.pendingEmail, 'topi@example.com');
    expect(auth.hasPendingPassword, isTrue);
  });

  test('username taken is a registration error and discards the password', () async {
    final auth = AuthController(
      repository: FakeAuthRepository(
        startRegistrationError: MessengerUsernameTakenException(
          username: 'Topi.J',
        ),
      ),
      session: FakeAuthSession(),
    );

    final started = await auth.startRegistration(
      email: 'topi@example.com',
      username: 'Topi.J',
      password: 'Password1!',
    );

    expect(started, isFalse);
    expect(auth.state.status, AuthStatus.error);
    expect(auth.state.errorMessage, contains('username is already taken'));
    expect(auth.hasPendingPassword, isFalse);
  });

  test(
    'a registration that cannot start shows a generic error and discards the password',
    () async {
      final auth = AuthController(
        repository: FakeAuthRepository(
          startRegistrationError: MessengerRegistrationIncompleteException(),
        ),
        session: FakeAuthSession(),
      );

      final started = await auth.startRegistration(
        email: 'topi@example.com',
        username: 'Topi.J',
        password: 'Password1!',
      );

      expect(started, isFalse);
      expect(auth.state.status, AuthStatus.error);
      expect(
        auth.state.errorMessage,
        AuthErrorMapper.registrationCouldNotStartMessage,
      );
      expect(auth.state.errorMessage, isNot(contains('already registered')));
      expect(auth.hasPendingPassword, isFalse);
    },
  );

  test('verifyRegistration success discards the password', () async {
    final repository = FakeAuthRepository(currentUser: testMessengerUser());
    final auth = AuthController(
      repository: repository,
      session: FakeAuthSession(),
    );
    await auth.startRegistration(
      email: 'topi@example.com',
      username: 'Topi.J',
      password: 'Password1!',
    );

    final finished = await auth.verifyRegistration(verificationCode: 'verify01');

    expect(finished, isTrue);
    expect(auth.state.status, AuthStatus.authenticated);
    expect(repository.lastFinishPassword, 'Password1!');
    expect(auth.hasPendingPassword, isFalse);
  });

  test('verifyRegistration failure stays pending with a generic message', () async {
    final auth = AuthController(
      repository: FakeAuthRepository(
        verifyRegistrationError: Exception('email already registered'),
      ),
      session: FakeAuthSession(),
    );
    await auth.startRegistration(
      email: 'topi@example.com',
      username: 'Topi.J',
      password: 'Password1!',
    );

    final finished = await auth.verifyRegistration(verificationCode: 'nope');

    expect(finished, isFalse);
    expect(auth.state.status, AuthStatus.awaitingVerification);
    expect(auth.state.errorMessage, AuthErrorMapper.verificationFailedMessage);
    expect(auth.state.errorMessage, isNot(contains('already')));
    expect(auth.hasPendingPassword, isTrue);
  });

  test('cancelRegistration discards the held password', () async {
    final auth = AuthController(
      repository: FakeAuthRepository(),
      session: FakeAuthSession(),
    );
    await auth.startRegistration(
      email: 'topi@example.com',
      username: 'Topi.J',
      password: 'Password1!',
    );

    auth.cancelRegistration();

    expect(auth.hasPendingPassword, isFalse);
    expect(auth.state.status, AuthStatus.unauthenticated);
  });

  test('startPasswordReset returns a request id without changing auth status', () async {
    final repository = FakeAuthRepository();
    final auth = AuthController(
      repository: repository,
      session: FakeAuthSession(),
    );
    await auth.restoreSession();

    final requestId = await auth.startPasswordReset(email: ' topi@example.com ');

    expect(requestId, testAuthUserId());
    expect(repository.lastStartPasswordResetEmail, 'topi@example.com');
    expect(auth.state.status, AuthStatus.unauthenticated);
    expect(auth.state.isBusy, isFalse);
    expect(auth.state.errorMessage, isNull);
  });

  test('startPasswordReset maps connection failure without naming the account', () async {
    final auth = AuthController(
      repository: FakeAuthRepository(
        startPasswordResetError: ServerpodClientException('down', 503),
      ),
      session: FakeAuthSession(),
    );
    await auth.restoreSession();

    final requestId = await auth.startPasswordReset(email: 'missing@example.com');

    expect(requestId, isNull);
    expect(auth.state.isBusy, isFalse);
    expect(auth.state.errorMessage, contains('connection error'));
    expect(auth.state.errorMessage, isNot(contains('not found')));
    expect(auth.state.errorMessage, isNot(contains('registered')));
    expect(auth.state.status, AuthStatus.unauthenticated);
  });

  test('finishPasswordReset sets the password then logs in with it', () async {
    final session = FakeAuthSession();
    final repository = FakeAuthRepository(currentUser: testMessengerUser());
    final auth = AuthController(repository: repository, session: session);
    await auth.restoreSession();

    final completed = await auth.finishPasswordReset(
      finishPasswordResetToken: 'reset-token',
      email: 'topi@example.com',
      newPassword: 'NewPass1!',
    );

    expect(completed, isTrue);
    expect(repository.lastFinishPasswordResetToken, 'reset-token');
    expect(repository.lastFinishNewPassword, 'NewPass1!');
    expect(repository.lastLoginEmail, 'topi@example.com');
    expect(repository.lastLoginPassword, 'NewPass1!');
    expect(session.authenticated, isTrue);
    expect(auth.state.status, AuthStatus.authenticated);
  });

  test('finishPasswordReset failure stays unauthenticated with a generic message', () async {
    final auth = AuthController(
      repository: FakeAuthRepository(
        finishPasswordResetError: EmailAccountPasswordResetException(
          reason: EmailAccountPasswordResetExceptionReason.invalid,
        ),
      ),
      session: FakeAuthSession(),
    );
    await auth.restoreSession();

    final completed = await auth.finishPasswordReset(
      finishPasswordResetToken: 'bad-token',
      email: 'topi@example.com',
      newPassword: 'NewPass1!',
    );

    expect(completed, isFalse);
    expect(auth.state.status, AuthStatus.unauthenticated);
    expect(auth.state.errorMessage, AuthErrorMapper.verificationFailedMessage);
    expect(auth.state.isAuthenticated, isFalse);
  });

  test('reconcileSession signs out only when the stored session is gone', () async {
    final session = FakeAuthSession(authenticated: true);
    final auth = AuthController(
      repository: FakeAuthRepository(currentUser: testMessengerUser()),
      session: session,
    );
    await auth.restoreSession();
    expect(auth.state.status, AuthStatus.authenticated);

    await auth.reconcileSession();
    expect(auth.state.status, AuthStatus.authenticated);

    session.authenticated = false;
    await auth.reconcileSession();
    expect(auth.state.status, AuthStatus.unauthenticated);
    expect(auth.state.isBusy, isFalse);
  });

  test('logout clears the session and returns to unauthenticated', () async {
    final session = FakeAuthSession(authenticated: true);
    final auth = AuthController(
      repository: FakeAuthRepository(currentUser: testMessengerUser()),
      session: session,
    );
    await auth.restoreSession();

    await auth.logout();

    expect(session.authenticated, isFalse);
    expect(auth.state.status, AuthStatus.unauthenticated);
  });
}
