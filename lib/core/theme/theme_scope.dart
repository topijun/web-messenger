import 'package:flutter/material.dart';
import 'package:mobile_messenger/core/theme/theme_controller.dart';

/// Provides the app-wide [ThemeController].
class ThemeScope extends InheritedNotifier<ThemeController> {
  /// Creates a [ThemeScope].
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  /// The nearest [ThemeController], if any.
  static ThemeController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeScope>()?.notifier;
  }

  /// The nearest [ThemeController].
  static ThemeController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'ThemeScope is missing from the widget tree.');
    return controller!;
  }
}
