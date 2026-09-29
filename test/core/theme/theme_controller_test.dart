import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_messenger/core/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('defaults to light before and after an empty load', () async {
    final controller = ThemeController(store: MemoryThemePreferenceStore());

    expect(controller.preference, AppThemePreference.light);
    expect(controller.themeMode, ThemeMode.light);

    await controller.load();

    expect(controller.preference, AppThemePreference.light);
    expect(controller.themeMode, ThemeMode.light);
    controller.dispose();
  });

  test('switching light to dark updates ThemeMode immediately', () async {
    final controller = ThemeController(store: MemoryThemePreferenceStore());
    await controller.load();

    await controller.setPreference(AppThemePreference.dark);

    expect(controller.preference, AppThemePreference.dark);
    expect(controller.themeMode, ThemeMode.dark);
    controller.dispose();
  });

  test('switching dark to light updates ThemeMode immediately', () async {
    final store = MemoryThemePreferenceStore(value: AppThemePreference.dark);
    final controller = ThemeController(store: store);
    await controller.load();
    expect(controller.themeMode, ThemeMode.dark);

    await controller.setPreference(AppThemePreference.light);

    expect(controller.preference, AppThemePreference.light);
    expect(controller.themeMode, ThemeMode.light);
    controller.dispose();
  });

  test('selected theme is restored from the same store', () async {
    final store = MemoryThemePreferenceStore();
    final first = ThemeController(store: store);
    await first.load();
    await first.setPreference(AppThemePreference.dark);
    first.dispose();

    final second = ThemeController(store: store);
    await second.load();

    expect(second.preference, AppThemePreference.dark);
    expect(second.themeMode, ThemeMode.dark);
    second.dispose();
  });

  test('SharedPreferences store persists light and dark', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesThemeStore(preferences: preferences);
    final first = ThemeController(store: store);
    await first.load();
    expect(first.preference, AppThemePreference.light);
    await first.setPreference(AppThemePreference.dark);
    first.dispose();

    final second = ThemeController(
      store: SharedPreferencesThemeStore(preferences: preferences),
    );
    await second.load();
    expect(second.preference, AppThemePreference.dark);
    await second.setPreference(AppThemePreference.light);
    expect(preferences.getString(SharedPreferencesThemeStore.key), 'light');
    second.dispose();
  });
}
