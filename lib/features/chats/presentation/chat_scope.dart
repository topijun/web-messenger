import 'package:flutter/material.dart';
import 'package:mobile_messenger/features/chats/data/chat_repository.dart';

/// Provides the app-wide [ChatRepository].
class ChatScope extends InheritedWidget {
  /// Creates a [ChatScope].
  const ChatScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final ChatRepository repository;

  /// The nearest [ChatRepository], if any.
  static ChatRepository? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ChatScope>()?.repository;
  }

  /// The nearest [ChatRepository].
  static ChatRepository of(BuildContext context) {
    final repository = maybeOf(context);
    assert(repository != null, 'ChatScope is missing from the widget tree.');
    return repository!;
  }

  @override
  bool updateShouldNotify(ChatScope oldWidget) =>
      repository != oldWidget.repository;
}
