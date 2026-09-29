import 'dart:async';

import 'package:flutter/material.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/features/chats/application/chat_controller.dart';
import 'package:mobile_messenger/features/chats/presentation/chat_detail_screen.dart';
import 'package:mobile_messenger/features/messaging/presentation/conversation_screen.dart';
import 'package:mobile_messenger/features/messaging/presentation/message_scope.dart';

/// Opens the existing conversation (or details if messages are unavailable).
///
/// Does not change archive state.
Future<void> openChat({
  required BuildContext context,
  required ChatController controller,
  required ChatSummary summary,
  int? selfProfileImageId,
}) async {
  final messages = MessageScope.maybeOf(context);
  controller.setActiveChat(summary.chat.id);
  try {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => messages == null
            ? ChatDetailScreen(controller: controller, summary: summary)
            : ConversationScreen(
                chatController: controller,
                summary: summary,
                messages: messages,
                selfProfileImageId: selfProfileImageId,
              ),
      ),
    );
  } finally {
    controller.setActiveChat(null);
    if (context.mounted) {
      unawaited(controller.load(silent: true));
    }
  }
}
