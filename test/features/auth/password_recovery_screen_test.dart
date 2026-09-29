import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/features/auth/application/auth_controller.dart';
import 'package:mobile_messenger/features/auth/presentation/auth_scope.dart';
import 'package:mobile_messenger/features/auth/presentation/login_screen.dart';
import 'package:mobile_messenger/features/auth/presentation/password_recovery_screen.dart';

import '../../support/auth_fakes.dart';

void main() {
  testWidgets('recovery screen renders the official Email IDP start step', (
    tester,
  ) async {
    final auth = await _readyAuth();

    await tester.pumpWidget(_harness(auth, const PasswordRecoveryScreen()));

    expect(find.text('Reset password'), findsOneWidget);
    expect(
      find.textContaining('If it is registered, we will send a verification code.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Send code'), findsOneWidget);
  });

  testWidgets('recovery screen rejects an empty email', (tester) async {
    final repository = FakeAuthRepository();
    final auth = await _readyAuth(repository: repository);

    await tester.pumpWidget(_harness(auth, const PasswordRecoveryScreen()));
    await tester.tap(find.widgetWithText(FilledButton, 'Send code'));
    await tester.pump();

    expect(find.text('Email is required.'), findsOneWidget);
    expect(repository.startPasswordResetCalls, 0);
  });

  testWidgets('recovery screen rejects a malformed email', (tester) async {
    final repository = FakeAuthRepository();
    final auth = await _readyAuth(repository: repository);

    await tester.pumpWidget(_harness(auth, const PasswordRecoveryScreen()));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'not-an-email',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Send code'));
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(repository.startPasswordResetCalls, 0);
  });

  testWidgets('successful reset request uses Email IDP start and shows the code step', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    final auth = await _readyAuth(repository: repository);

    await tester.pumpWidget(_harness(auth, const PasswordRecoveryScreen()));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'topi@example.com',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Send code'));
    await tester.pumpAndSettle();

    expect(repository.startPasswordResetCalls, 1);
    expect(repository.lastStartPasswordResetEmail, 'topi@example.com');
    expect(find.text('Enter the verification code sent to your email.'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Verification code'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Verify code'), findsOneWidget);
    expect(find.text('Resend code'), findsOneWidget);
  });

  testWidgets('reset request shows a loading state until Email IDP returns', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    repository.startPasswordResetCompleter = Completer<UuidValue>();
    final auth = await _readyAuth(repository: repository);

    await tester.pumpWidget(_harness(auth, const PasswordRecoveryScreen()));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'topi@example.com',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Send code'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

    repository.startPasswordResetCompleter!.complete(testAuthUserId());
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Verify code'), findsOneWidget);
  });

  testWidgets('failed reset request stays on the email step in a usable state', (
    tester,
  ) async {
    final repository = FakeAuthRepository(
      startPasswordResetError: ServerpodClientException('down', 503),
    );
    final auth = await _readyAuth(repository: repository);

    await tester.pumpWidget(_harness(auth, const PasswordRecoveryScreen()));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'topi@example.com',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Send code'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'A connection error occurred. Please check your internet connection and try again.',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Send code'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('login can open recovery and return afterward', (tester) async {
    final auth = await _readyAuth();

    await tester.pumpWidget(_harness(auth, const LoginScreen()));
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(find.text('Reset password'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Log in'), findsOneWidget);
  });

  testWidgets('completed reset returns to login after Email IDP finish', (
    tester,
  ) async {
    final repository = FakeAuthRepository(currentUser: testMessengerUser());
    final auth = await _readyAuth(repository: repository);

    await tester.pumpWidget(_harness(auth, const LoginScreen()));
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'topi@example.com',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Send code'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Verification code'),
      'reset001',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Verify code'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'New password'),
      'NewPass1!',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm password'),
      'NewPass1!',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Reset password'));
    await tester.pumpAndSettle();

    expect(repository.lastVerifyPasswordResetCode, 'reset001');
    expect(repository.lastFinishPasswordResetToken, 'reset-token');
    expect(repository.lastFinishNewPassword, 'NewPass1!');
    expect(repository.lastLoginEmail, 'topi@example.com');
    expect(repository.lastLoginPassword, 'NewPass1!');
    expect(find.widgetWithText(FilledButton, 'Log in'), findsOneWidget);
  });
}

Future<AuthController> _readyAuth({FakeAuthRepository? repository}) async {
  final auth = AuthController(
    repository: repository ?? FakeAuthRepository(),
    session: FakeAuthSession(),
  );
  await auth.restoreSession();
  return auth;
}

Widget _harness(AuthController auth, Widget home) {
  return AuthScope(
    controller: auth,
    child: ListenableBuilder(
      listenable: auth,
      builder: (_, _) => MaterialApp(home: home),
    ),
  );
}
