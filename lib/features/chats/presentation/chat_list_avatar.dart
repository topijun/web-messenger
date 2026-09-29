import 'package:flutter/material.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/features/profile/presentation/widgets/profile_avatar.dart';

/// Avatar for a chat-list row: the other user, or a group stack.
class ChatListAvatar extends StatelessWidget {
  /// Creates a [ChatListAvatar].
  const ChatListAvatar({super.key, required this.summary});

  final ChatSummary summary;

  @override
  Widget build(BuildContext context) {
    final chatId = summary.chat.id;
    if (summary.chat.type == ChatType.group) {
      return GroupAvatarStack(
        key: Key('groupChatAvatar-$chatId'),
        imageIds: [
          for (final avatar in summary.otherAvatars) avatar.profileImageId,
        ],
      );
    }
    return ProfileAvatar(
      key: Key('directChatAvatar-$chatId'),
      profileImageId: summary.otherAvatars.isEmpty
          ? null
          : summary.otherAvatars.first.profileImageId,
    );
  }
}
