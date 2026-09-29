import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-selected appearance. System theme is not used.
enum AppThemePreference {
  /// Light Material theme.
  light,

  /// Dark Material theme.
  dark;

  /// Parses a stored name, or null when missing/invalid.
  static AppThemePreference? tryParse(String? value) {
    return switch (value) {
      'light' => AppThemePreference.light,
      'dark' => AppThemePreference.dark,
      _ => null,
    };
  }
}

/// Reads and writes the selected [AppThemePreference].
abstract class ThemePreferenceStore {
  /// The stored preference, or null when the user has never chosen one.
  Future<AppThemePreference?> read();

  /// Persists [preference].
  Future<void> write(AppThemePreference preference);
}

/// [ThemePreferenceStore] backed by SharedPreferences.
class SharedPreferencesThemeStore implements ThemePreferenceStore {
  /// Creates a [SharedPreferencesThemeStore].
  SharedPreferencesThemeStore({SharedPreferences? preferences})
    : _preferences = preferences;

  /// Storage key for the selected appearance.
  static const key = 'messenger.theme.preference';

  SharedPreferences? _preferences;

  Future<SharedPreferences> _instance() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  @override
  Future<AppThemePreference?> read() async {
    final preferences = await _instance();
    return AppThemePreference.tryParse(preferences.getString(key));
  }

  @override
  Future<void> write(AppThemePreference preference) async {
    final preferences = await _instance();
    await preferences.setString(key, preference.name);
  }
}

/// In-memory store used by tests and when no store is injected.
class MemoryThemePreferenceStore implements ThemePreferenceStore {
  /// Creates a [MemoryThemePreferenceStore].
  MemoryThemePreferenceStore({this.value});

  /// Last written value.
  AppThemePreference? value;

  @override
  Future<AppThemePreference?> read() async => value;

  @override
  Future<void> write(AppThemePreference preference) async {
    value = preference;
  }
}

/// Owns the process-wide appearance setting.
class ThemeController extends ChangeNotifier {
  /// Creates a [ThemeController] that defaults to light until [load].
  ThemeController({required ThemePreferenceStore store}) : _store = store;

  final ThemePreferenceStore _store;
  var _preference = AppThemePreference.light;
  Future<void>? _writeInFlight;

  /// Selected appearance. Defaults to light.
  AppThemePreference get preference => _preference;

  /// [ThemeMode] passed to [MaterialApp].
  ThemeMode get themeMode => switch (_preference) {
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };

  /// Restores the stored selection. Missing values stay light.
  Future<void> load() async {
    _preference = await _store.read() ?? AppThemePreference.light;
    notifyListeners();
  }

  /// Updates the theme immediately and persists the selection.
  Future<void> setPreference(AppThemePreference preference) async {
    if (_preference == preference) {
      return;
    }
    _preference = preference;
    notifyListeners();
    _writeInFlight = _store.write(preference);
    await _writeInFlight;
  }
}
