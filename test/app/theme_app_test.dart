import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_messenger/app/messenger_app.dart';
import 'package:mobile_messenger/core/theme/theme_controller.dart';
import 'package:mobile_messenger/features/auth/application/auth_controller.dart';

import '../support/auth_fakes.dart';

void main() {
  testWidgets('MessengerApp defaults to the light theme', (tester) async {
    final auth = AuthController(
      repository: FakeAuthRepository(),
      session: FakeAuthSession(),
    );

    await tester.pumpWidget(MessengerApp(auth: auth));
    await tester.pumpAndSettle();

    expect(_appBrightness(tester), Brightness.light);
  });

  testWidgets('changing ThemeController updates MaterialApp immediately', (
    tester,
  ) async {
    final auth = AuthController(
      repository: FakeAuthRepository(),
      session: FakeAuthSession(),
    );
    final theme = ThemeController(store: MemoryThemePreferenceStore());
    await theme.load();

    await tester.pumpWidget(MessengerApp(auth: auth, theme: theme));
    await tester.pumpAndSettle();
    expect(_themeMode(tester), ThemeMode.light);
    expect(_appBrightness(tester), Brightness.light);

    await theme.setPreference(AppThemePreference.dark);
    await tester.pumpAndSettle();
    expect(_themeMode(tester), ThemeMode.dark);
    expect(_appBrightness(tester), Brightness.dark);

    await theme.setPreference(AppThemePreference.light);
    await tester.pumpAndSettle();
    expect(_themeMode(tester), ThemeMode.light);
    expect(_appBrightness(tester), Brightness.light);
    theme.dispose();
  });
}

ThemeMode? _themeMode(WidgetTester tester) {
  return tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode;
}

Brightness _appBrightness(WidgetTester tester) {
  return Theme.of(tester.element(find.text('Log in'))).brightness;
}
