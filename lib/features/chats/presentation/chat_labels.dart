import 'package:messenger_client/messenger_client.dart';

/// Display title for a chat list row.
String chatTitle(ChatSummary summary) {
  if (summary.chat.type == ChatType.group) {
    final name = summary.chat.name?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return 'Group';
  }
  if (summary.otherUsernames.isEmpty) {
    return 'Direct chat';
  }
  return summary.otherUsernames.join(', ');
}

/// Subtitle shown for a pending invitation.
String invitationSubtitle(ChatInvitationView view) {
  if (view.isGroup) {
    final name = view.chatName?.trim();
    if (name != null && name.isNotEmpty) {
      return '${view.senderUsername} invited you to $name';
    }
    return '${view.senderUsername} invited you to a group';
  }
  return '${view.senderUsername} invited you to a direct chat';
}
