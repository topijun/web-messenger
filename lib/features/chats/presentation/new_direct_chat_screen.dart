import 'package:flutter/material.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/features/chats/application/chat_controller.dart';
import 'package:mobile_messenger/features/profile/presentation/widgets/profile_avatar.dart';

/// Form to search for a user by username or email and send a direct invitation.
class NewDirectChatScreen extends StatefulWidget {
  /// Creates a [NewDirectChatScreen].
  const NewDirectChatScreen({super.key, required this.controller});

  final ChatController controller;

  @override
  State<NewDirectChatScreen> createState() => _NewDirectChatScreenState();
}

class _NewDirectChatScreenState extends State<NewDirectChatScreen> {
  final _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    await widget.controller.searchContact(_queryController.text);
  }

  Future<void> _send() async {
    final username = widget.controller.contact?.username;
    if (username == null) {
      return;
    }
    final sent = await widget.controller.inviteDirect(username);
    if (!mounted) {
      return;
    }
    if (sent) {
      Navigator.of(context).pop(true);
      return;
    }
    final message = widget.controller.errorMessage;
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search contacts')),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final contact = widget.controller.contact;
          final canInvite = contact?.relation == ContactSearchRelation.none;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  key: const Key('directInviteUsername'),
                  controller: _queryController,
                  textInputAction: TextInputAction.search,
                  onChanged: (_) => widget.controller.clearContactSearch(),
                  onSubmitted: (_) => _search(),
                  decoration: const InputDecoration(
                    labelText: 'Username or email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  key: const Key('lookupUsername'),
                  onPressed: widget.controller.searching ? null : _search,
                  child: widget.controller.searching
                      ? const SizedBox(
                          key: Key('contactSearchLoading'),
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Search'),
                ),
                const SizedBox(height: 16),
                if (widget.controller.contactFeedback != null)
                  Text(
                    widget.controller.contactFeedback!,
                    key: const Key('contactSearchFeedback'),
                  ),
                if (contact != null) ...[
                  _ContactResultTile(contact: contact),
                  const SizedBox(height: 12),
                  if (canInvite)
                    FilledButton(
                      key: const Key('sendDirectInvitation'),
                      onPressed: widget.controller.actionBusy ? null : _send,
                      child: const Text('Invite'),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ContactResultTile extends StatelessWidget {
  const _ContactResultTile({required this.contact});

  final ContactSearchResult contact;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: const Key('contactSearchResult'),
      contentPadding: EdgeInsets.zero,
      leading: ProfileAvatar(
        key: const Key('contactSearchAvatar'),
        profileImageId: contact.profileImageId,
        size: 40,
      ),
      title: Text(contact.username, key: const Key('contactSearchUsername')),
      subtitle: Text(
        _relationLabel(contact.relation),
        key: const Key('contactSearchRelation'),
      ),
    );
  }
}

String _relationLabel(ContactSearchRelation relation) {
  return switch (relation) {
    ContactSearchRelation.none => 'Invite',
    ContactSearchRelation.self => 'You cannot invite yourself',
    ContactSearchRelation.chatting => 'Already chatting',
    ContactSearchRelation.invitationSent => 'Invitation pending',
    ContactSearchRelation.invitationReceived => 'Invitation received',
  };
}
