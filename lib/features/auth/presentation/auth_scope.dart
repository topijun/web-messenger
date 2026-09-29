import 'package:flutter/material.dart';
import 'package:mobile_messenger/features/auth/application/auth_controller.dart';

/// Provides the app-wide [AuthController].
class AuthScope extends InheritedNotifier<AuthController> {
  /// Creates an [AuthScope].
  const AuthScope({
    super.key,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  /// The nearest [AuthController].
  static AuthController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope is missing from the widget tree.');
    return scope!.notifier!;
  }
}
