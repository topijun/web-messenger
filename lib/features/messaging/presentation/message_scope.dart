import 'package:flutter/material.dart';
import 'package:mobile_messenger/features/messaging/data/message_repository.dart';

/// Provides the app-wide [MessageRepository].
class MessageScope extends InheritedWidget {
  /// Creates a [MessageScope].
  const MessageScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final MessageRepository repository;

  /// The nearest [MessageRepository], if any.
  static MessageRepository? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MessageScope>()
        ?.repository;
  }

  /// The nearest [MessageRepository].
  static MessageRepository of(BuildContext context) {
    final repository = maybeOf(context);
    assert(repository != null, 'MessageScope is missing from the widget tree.');
    return repository!;
  }

  @override
  bool updateShouldNotify(MessageScope oldWidget) =>
      repository != oldWidget.repository;
}
