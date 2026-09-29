import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_messenger/app/messenger_app.dart';
import 'package:mobile_messenger/features/auth/application/auth_controller.dart';
import 'package:mobile_messenger/features/auth/domain/auth_state.dart';
import 'package:mobile_messenger/features/auth/presentation/auth_gate.dart';
import 'package:mobile_messenger/features/auth/presentation/auth_scope.dart';

import '../../support/auth_fakes.dart';

void main() {
  testWidgets('startup shows an auth-check state then login', (tester) async {
    final auth = AuthController(
      repository: FakeAuthRepository(),
      session: FakeAuthSession(),
    );

    await tester.pumpWidget(
      AuthScope(
        controller: auth,
        child: ListenableBuilder(
          listenable: auth,
          builder: (_, _) => const MaterialApp(home: AuthGate()),
        ),
      ),
    );
    expect(auth.state.status, AuthStatus.checking);
    expect(find.text('Checking signed-in status…'), findsOneWidget);

    await auth.restoreSession();
    await tester.pumpAndSettle();
    expect(auth.state.status, AuthStatus.unauthenticated);
    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('startup with a stored session shows the authenticated home', (
    tester,
  ) async {
    final auth = AuthController(
      repository: FakeAuthRepository(currentUser: testMessengerUser()),
      session: FakeAuthSession(authenticated: true),
    );

    await tester.pumpWidget(MessengerApp(auth: auth));
    await tester.pumpAndSettle();

    expect(auth.state.status, AuthStatus.authenticated);
    expect(find.text('Signed in as Topi.J'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
    expect(find.text('Log in'), findsNothing);
  });
}
