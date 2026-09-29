import 'package:flutter/material.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/features/chats/application/chat_controller.dart';
import 'package:mobile_messenger/features/chats/presentation/chat_nav_title.dart';
import 'package:mobile_messenger/features/profile/presentation/widgets/profile_avatar.dart';

/// Membership settings and members for one chat.
class ChatDetailScreen extends StatefulWidget {
  /// Creates a [ChatDetailScreen].
  const ChatDetailScreen({
    super.key,
    required this.controller,
    required this.summary,
  });

  final ChatController controller;
  final ChatSummary summary;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _queryController = TextEditingController();
  List<ChatMember>? _members;
  String? _membersError;
  var _loadingMembers = true;

  ChatSummary get _summary {
    final id = widget.summary.chat.id;
    for (final summary in widget.controller.chats) {
      if (summary.chat.id == id) {
        return summary;
      }
    }
    return widget.summary;
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    widget.controller.clearContactSearch();
    _loadMembers();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _queryController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  bool _isMember(String username) {
    final needle = username.toLowerCase();
    return _members?.any(
          (member) => member.username.toLowerCase() == needle,
        ) ??
        false;
  }

  Future<void> _loadMembers() async {
    final chatId = widget.summary.chat.id;
    if (chatId == null) {
      setState(() {
        _loadingMembers = false;
        _membersError = 'That chat could not be found.';
      });
      return;
    }
    if (!_loadingMembers) {
      setState(() {
        _loadingMembers = true;
        _membersError = null;
      });
    }
    try {
      final members = await widget.controller.listMembers(chatId);
      if (!mounted) {
        return;
      }
      setState(() {
        _members = members;
        _loadingMembers = false;
        _membersError = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingMembers = false;
        _membersError = 'Could not load members.';
      });
    }
  }

  Future<void> _toggleArchived(bool archived) async {
    final chatId = _summary.chat.id;
    if (chatId == null) {
      return;
    }
    final ok = await widget.controller.setArchived(
      chatId: chatId,
      archived: archived,
    );
    _showActionResult(ok, archived ? 'Chat archived.' : 'Chat unarchived.');
  }

  Future<void> _toggleMuted(bool muted) async {
    final chatId = _summary.chat.id;
    if (chatId == null) {
      return;
    }
    final ok = await widget.controller.setMuted(
      chatId: chatId,
      notificationsMuted: muted,
    );
    _showActionResult(
      ok,
      muted ? 'Notifications muted.' : 'Notifications unmuted.',
    );
  }

  Future<void> _search() async {
    await widget.controller.searchContact(_queryController.text);
  }

  Future<void> _invite() async {
    final chatId = _summary.chat.id;
    final username = widget.controller.contact?.username;
    if (chatId == null || username == null) {
      return;
    }
    final ok = await widget.controller.inviteToGroup(
      chatId: chatId,
      username: username,
    );
    if (ok) {
      _queryController.clear();
      widget.controller.clearContactSearch();
      await _loadMembers();
    }
    _showActionResult(ok, 'Invitation sent.');
  }

  void _showActionResult(bool ok, String success) {
    if (!mounted) {
      return;
    }
    final message = ok ? success : widget.controller.errorMessage;
    if (message == null) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    final isGroup = summary.chat.type == ChatType.group;
    final isAdmin = summary.membership.role == ChatParticipantRole.admin;

    return Scaffold(
      appBar: AppBar(title: ChatNavTitle(summary: summary)),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final contact = widget.controller.contact;
          final alreadyMember = contact != null && _isMember(contact.username);
          final canInvite =
              contact != null &&
              contact.relation != ContactSearchRelation.self &&
              !alreadyMember;
          return ListView(
            key: const Key('chatDetailScroll'),
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                key: const Key('archiveChat'),
                title: Text(
                  summary.membership.archived ? 'Unarchive' : 'Archived',
                ),
                value: summary.membership.archived,
                onChanged: widget.controller.actionBusy
                    ? null
                    : _toggleArchived,
              ),
              SwitchListTile(
                key: const Key('muteChat'),
                title: const Text('Mute notifications'),
                value: summary.membership.notificationsMuted,
                onChanged: widget.controller.actionBusy ? null : _toggleMuted,
              ),
              const SizedBox(height: 12),
              Text('Members', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (_loadingMembers)
                const Center(child: CircularProgressIndicator())
              else if (_membersError != null)
                Text(_membersError!)
              else
                for (final member in _members ?? const <ChatMember>[])
                  ListTile(
                    key: Key('chatMember-${member.userId}'),
                    contentPadding: EdgeInsets.zero,
                    leading: ProfileAvatar(
                      key: Key('chatMemberAvatar-${member.userId}'),
                      profileImageId: member.profileImageId,
                      size: 40,
                    ),
                    title: Text(member.username),
                    subtitle: Text(member.role.name),
                  ),
              if (isGroup) ...[
                const SizedBox(height: 16),
                Text(
                  'Add members',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (!isAdmin)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Only a group admin can invite people. The server will reject other attempts.',
                    ),
                  ),
                TextField(
                  key: const Key('groupInviteUsername'),
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
                  key: const Key('groupSearchContact'),
                  onPressed: widget.controller.searching ? null : _search,
                  child: widget.controller.searching
                      ? const SizedBox(
                          key: Key('groupContactSearchLoading'),
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Search'),
                ),
                const SizedBox(height: 12),
                if (widget.controller.contactFeedback != null)
                  Text(
                    widget.controller.contactFeedback!,
                    key: const Key('groupContactSearchFeedback'),
                  ),
                if (contact != null)
                  ListTile(
                    key: const Key('groupContactSearchResult'),
                    contentPadding: EdgeInsets.zero,
                    leading: ProfileAvatar(
                      key: const Key('groupContactSearchAvatar'),
                      profileImageId: contact.profileImageId,
                      size: 40,
                    ),
                    title: Text(
                      contact.username,
                      key: const Key('groupContactSearchUsername'),
                    ),
                    subtitle: Text(
                      contact.relation == ContactSearchRelation.self
                          ? 'You cannot invite yourself'
                          : alreadyMember
                          ? 'Already a member'
                          : 'Invite',
                      key: const Key('groupContactSearchRelation'),
                    ),
                    trailing: canInvite
                        ? FilledButton(
                            key: const Key('inviteToGroup'),
                            onPressed: widget.controller.actionBusy
                                ? null
                                : _invite,
                            child: const Text('Invite'),
                          )
                        : null,
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
