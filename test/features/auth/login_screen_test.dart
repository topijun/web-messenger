import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_messenger/features/auth/application/auth_controller.dart';
import 'package:mobile_messenger/features/auth/presentation/auth_scope.dart';
import 'package:mobile_messenger/features/auth/presentation/login_screen.dart';

import '../../support/auth_fakes.dart';

void main() {
  testWidgets('login form validates empty email and password', (tester) async {
    final auth = await _readyAuth();

    await tester.pumpWidget(_harness(auth, const LoginScreen()));
    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
  });

  testWidgets('login form rejects an invalid email', (tester) async {
    final auth = await _readyAuth();

    await tester.pumpWidget(_harness(auth, const LoginScreen()));
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'not-an-email');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'secret');
    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });

  testWidgets('login form has links to registration and password recovery', (
    tester,
  ) async {
    final auth = await _readyAuth();

    await tester.pumpWidget(_harness(auth, const LoginScreen()));

    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('Forgot password opens recovery and the back action returns to login', (
    tester,
  ) async {
    final auth = await _readyAuth();

    await tester.pumpWidget(_harness(auth, const LoginScreen()));
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(find.text('Reset password'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Log in'), findsOneWidget);
  });
}

Future<AuthController> _readyAuth() async {
  final auth = AuthController(
    repository: FakeAuthRepository(),
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
