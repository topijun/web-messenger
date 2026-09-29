import 'package:flutter/material.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/features/chats/presentation/chat_labels.dart';
import 'package:mobile_messenger/features/profile/presentation/widgets/profile_avatar.dart';

/// AppBar title with the group avatar pile or the other user's direct-chat avatar.
class ChatNavTitle extends StatelessWidget {
  /// Creates a [ChatNavTitle].
  const ChatNavTitle({super.key, required this.summary});

  final ChatSummary summary;

  @override
  Widget build(BuildContext context) {
    final title = Text(chatTitle(summary), overflow: TextOverflow.ellipsis);
    final avatar = summary.chat.type == ChatType.group
        ? GroupAvatarStack(
            key: Key('groupNavAvatar-${summary.chat.id}'),
            imageIds: [
              for (final avatar in summary.otherAvatars) avatar.profileImageId,
            ],
            size: 32,
          )
        : ProfileAvatar(
            key: Key('directNavAvatar-${summary.chat.id}'),
            profileImageId: summary.otherAvatars.isEmpty
                ? null
                : summary.otherAvatars.first.profileImageId,
            size: 32,
          );
    return Row(
      children: [
        avatar,
        const SizedBox(width: 10),
        Expanded(child: title),
      ],
    );
  }
}
