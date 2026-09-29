import 'package:flutter/material.dart';

/// Light and dark [ThemeData] for Mobile Messenger.
///
/// Both schemes use the existing teal seed. Dark mode uses Material 3 dark
/// surfaces rather than inverted light colors.
class AppTheme {
  /// Existing application accent.
  static const seedColor = Color(0xFF1B6B6B);

  /// Creates an [AppTheme].
  const AppTheme._();

  /// Light Material 3 theme used as the application default.
  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
  }

  /// Dark Material 3 theme that keeps the teal accent and existing shapes.
  static ThemeData get dark {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }
}
