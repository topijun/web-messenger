import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/core/errors/auth_error_mapper.dart';
import 'package:mobile_messenger/features/auth/application/auth_controller.dart';
import 'package:mobile_messenger/features/auth/presentation/auth_scope.dart';
import 'package:mobile_messenger/features/auth/presentation/register_screen.dart';

import '../../support/auth_fakes.dart';

void main() {
  testWidgets('registration form validates username and password rules', (
    tester,
  ) async {
    final auth = await _readyAuth();

    await tester.pumpWidget(_harness(auth));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'topi@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'to',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'password',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm password'),
      'password',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pump();

    expect(
      find.text('Username must be at least 3 characters.'),
      findsOneWidget,
    );
    expect(
      find.text('Password does not meet the strength requirements.'),
      findsOneWidget,
    );
    expect(find.text('At least 8 characters'), findsOneWidget);
  });

  testWidgets('registration form requires matching password confirmation', (
    tester,
  ) async {
    final auth = await _readyAuth();

    await tester.pumpWidget(_harness(auth));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'topi@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'Topi.J',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'Password1!',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm password'),
      'Password1!!',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pump();

    expect(find.text('Passwords do not match.'), findsOneWidget);
  });

  testWidgets('valid registration starts the verification step', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    final auth = AuthController(
      repository: repository,
      session: FakeAuthSession(),
    );
    await auth.restoreSession();

    await tester.pumpWidget(_harness(auth));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'topi@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'Topi.J',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'Password1!',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm password'),
      'Password1!',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(repository.startRegistrationCalls, 1);
    expect(repository.lastStartUsername, 'Topi.J');
    expect(find.text('Verify email'), findsOneWidget);
    expect(find.textContaining('topi@example.com'), findsOneWidget);
  });

  testWidgets(
    'a registration that cannot start stays on the form with a generic error',
    (tester) async {
      final auth = await _readyAuth(
        repository: FakeAuthRepository(
          startRegistrationError: MessengerRegistrationIncompleteException(),
        ),
      );

      await tester.pumpWidget(_harness(auth));
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'topi@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        'Topi.J',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'Password1!',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm password'),
        'Password1!',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pumpAndSettle();

      expect(find.text('Verify email'), findsNothing);
      expect(
        find.text(AuthErrorMapper.registrationCouldNotStartMessage),
        findsOneWidget,
      );
      expect(find.textContaining('already registered'), findsNothing);
    },
  );
}

Future<AuthController> _readyAuth({FakeAuthRepository? repository}) async {
  final auth = AuthController(
    repository: repository ?? FakeAuthRepository(),
    session: FakeAuthSession(),
  );
  await auth.restoreSession();
  return auth;
}

Widget _harness(AuthController auth) {
  return AuthScope(
    controller: auth,
    child: ListenableBuilder(
      listenable: auth,
      builder: (_, _) => const MaterialApp(home: RegisterScreen()),
    ),
  );
}
