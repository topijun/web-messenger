import 'dart:async';

import 'package:flutter/material.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/core/lifecycle/app_resume_guard.dart';
import 'package:mobile_messenger/features/auth/presentation/auth_scope.dart';
import 'package:mobile_messenger/features/chats/application/chat_controller.dart';
import 'package:mobile_messenger/features/chats/presentation/chat_detail_screen.dart';
import 'package:mobile_messenger/features/chats/presentation/chat_labels.dart';
import 'package:mobile_messenger/features/chats/presentation/chat_list_avatar.dart';
import 'package:mobile_messenger/features/chats/presentation/open_chat.dart';
import 'package:mobile_messenger/features/chats/presentation/new_direct_chat_screen.dart';
import 'package:mobile_messenger/features/chats/presentation/new_group_screen.dart';
import 'package:mobile_messenger/features/home/presentation/messenger_layout.dart';
import 'package:mobile_messenger/features/messaging/presentation/conversation_screen.dart';
import 'package:mobile_messenger/features/messaging/presentation/message_scope.dart';
import 'package:mobile_messenger/features/profile/application/profile_controller.dart';
import 'package:mobile_messenger/features/profile/presentation/profile_scope.dart';
import 'package:mobile_messenger/features/profile/presentation/profile_screen.dart';
import 'package:mobile_messenger/features/profile/presentation/widgets/profile_avatar.dart';

/// Authenticated chat list and pending invitations.
class ChatHomeScreen extends StatefulWidget {
  /// Creates a [ChatHomeScreen].
  const ChatHomeScreen({
    super.key,
    required this.controller,
    this.profile,
    this.homePollInterval = const Duration(seconds: 10),
    this.invitationPollInterval = const Duration(seconds: 5),
  });

  final ChatController controller;
  final ProfileController? profile;

  /// Safety-net poll while the Chats tab is visible and the app is resumed.
  final Duration homePollInterval;

  /// Safety-net poll while the Invitations tab is visible and the app is resumed.
  final Duration invitationPollInterval;

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final _resume = AppResumeGuard();
  late final TabController _tabs;
  Timer? _poll;
  var _appActive = true;
  var _wide = false;
  int? _selectedChatId;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(_onTabChanged);
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_onControllerChanged);
    widget.profile?.addListener(_onControllerChanged);
    if (widget.controller.status == ChatStatus.loading &&
        widget.controller.chats.isEmpty &&
        widget.controller.invitations.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.controller.status == ChatStatus.loading) {
          widget.controller.load();
        }
      });
    }
    _restartPolling();
  }

  @override
  void dispose() {
    _stopPolling();
    _tabs.removeListener(_onTabChanged);
    _tabs.dispose();
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_onControllerChanged);
    widget.profile?.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final shouldRefresh = _resume.shouldRefresh(state);
    if (state == AppLifecycleState.resumed) {
      _appActive = true;
      widget.controller.resubscribeWatch();
      if (shouldRefresh) {
        unawaited(_resume.run(() => widget.controller.load(silent: true)));
      }
      _restartPolling();
      return;
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _appActive = false;
      _stopPolling();
    }
  }

  void _onTabChanged() {
    if (_tabs.indexIsChanging) {
      return;
    }
    if (_tabs.index == 1) {
      unawaited(widget.controller.load(silent: true));
    }
    _restartPolling();
  }

  void _restartPolling() {
    _poll?.cancel();
    _poll = null;
    if (!_appActive || !mounted) {
      return;
    }
    final interval = _tabs.index == 1
        ? widget.invitationPollInterval
        : widget.homePollInterval;
    if (interval <= Duration.zero) {
      return;
    }
    _poll = Timer.periodic(interval, (_) {
      unawaited(widget.controller.poll());
    });
  }

  void _stopPolling() {
    _poll?.cancel();
    _poll = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wide = isMessengerWideLayout(context);
    if (_wide && !wide) {
      _selectedChatId = null;
      widget.controller.setActiveChat(null);
    }
    _wide = wide;
  }

  void _onControllerChanged() {
    if (_selectedChatId != null && _summaryFor(_selectedChatId) == null) {
      _selectedChatId = null;
      widget.controller.setActiveChat(null);
    }
    if (mounted) {
      setState(() {});
    }
  }

  ChatSummary? _summaryFor(int? chatId) {
    if (chatId == null) {
      return null;
    }
    for (final summary in widget.controller.chats) {
      if (summary.chat.id == chatId) {
        return summary;
      }
    }
    return null;
  }

  Future<void> _openProfile() async {
    final existing = widget.profile;
    if (existing != null) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ProfileScreen(
            controller: existing,
            chats: widget.controller,
          ),
        ),
      );
      final mediaId = existing.profile?.profileImageId;
      final bytes = existing.imageBytes;
      if (!mounted) {
        return;
      }
      if (mediaId != null && bytes != null) {
        ProfileScope.maybeScopeOf(context)?.images.remember(mediaId, bytes);
      }
      return;
    }
    final auth = AuthScope.of(context);
    final profiles = ProfileScope.maybeOf(context);
    if (profiles == null) {
      return;
    }
    final controller = ProfileController(
      repository: profiles,
      username: auth.state.username ?? 'Unknown',
    );
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfileScreen(
          controller: controller,
          chats: widget.controller,
        ),
      ),
    );
    controller.dispose();
  }

  Future<void> _openNewChatMenu() async {
    final choice = await showModalBottomSheet<_NewChatChoice>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                key: const Key('newDirectChat'),
                leading: const Icon(Icons.person_add_outlined),
                title: const Text('New direct chat'),
                onTap: () => Navigator.pop(context, _NewChatChoice.direct),
              ),
              ListTile(
                key: const Key('newGroupChat'),
                leading: const Icon(Icons.group_add_outlined),
                title: const Text('New group'),
                onTap: () => Navigator.pop(context, _NewChatChoice.group),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted || choice == null) {
      return;
    }
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => choice == _NewChatChoice.direct
            ? NewDirectChatScreen(controller: widget.controller)
            : NewGroupScreen(controller: widget.controller),
      ),
    );
    if (!mounted) {
      return;
    }
    if (created == true) {
      _showMessage(
        choice == _NewChatChoice.direct
            ? 'Invitation sent. It will appear under Invitations for the other user.'
            : 'Group created.',
      );
    }
  }

  Future<void> _openChat(ChatSummary summary) {
    if (isMessengerWideLayout(context)) {
      final chatId = summary.chat.id;
      setState(() => _selectedChatId = chatId);
      if (chatId != null) {
        widget.controller.setActiveChat(chatId);
      }
      return Future<void>.value();
    }
    return openChat(
      context: context,
      controller: widget.controller,
      summary: summary,
      selfProfileImageId: widget.profile?.profile?.profileImageId,
    );
  }

  Future<void> _accept(int invitationId) async {
    final ok = await widget.controller.accept(invitationId);
    if (!mounted) {
      return;
    }
    _showMessage(ok ? 'Invitation accepted.' : widget.controller.errorMessage);
  }

  Future<void> _decline(int invitationId) async {
    final ok = await widget.controller.decline(invitationId);
    if (!mounted) {
      return;
    }
    _showMessage(ok ? 'Invitation declined.' : widget.controller.errorMessage);
  }

  void _showMessage(String? message) {
    if (message == null) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final profiles = ProfileScope.maybeOf(context);
    final controller = widget.controller;

    final wide = isMessengerWideLayout(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ProfileAvatar(
              key: const Key('homeProfileAvatar'),
              profileImageId: widget.profile?.profile?.profileImageId,
              bytes: widget.profile?.imageBytes,
              size: 36,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Messenger'),
                  if (auth.state.username != null)
                    Text(
                      auth.state.username!,
                      key: const Key('homeUsername'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: const Key('refreshChats'),
            tooltip: 'Refresh',
            onPressed: controller.isBusy ? null : controller.load,
            icon: const Icon(Icons.refresh),
          ),
          if (profiles != null)
            IconButton(
              key: const Key('openProfile'),
              tooltip: 'Profile',
              icon: const Icon(Icons.person_outline),
              onPressed: _openProfile,
            ),
          TextButton(
            onPressed: auth.state.isBusy ? null : auth.logout,
            child: const Text('Log out'),
          ),
        ],
        bottom: wide ? null : _homeTabs(controller),
      ),
      floatingActionButton: wide ? null : _newChatButton(),
      body: wide ? _wideBody(controller) : _homePages(controller),
    );
  }

  TabBar _homeTabs(ChatController controller, {bool scrollable = false}) {
    return TabBar(
      controller: _tabs,
      isScrollable: scrollable,
      tabAlignment: scrollable ? TabAlignment.start : TabAlignment.fill,
      tabs: [
        const Tab(key: Key('chatsTab'), text: 'Chats'),
        Tab(
          key: const Key('invitationsTab'),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Invitations'),
              if (controller.pendingInvitationCount > 0) ...[
                const SizedBox(width: 8),
                _CountBadge(
                  key: const Key('invitationBadge'),
                  count: controller.pendingInvitationCount,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _newChatButton() {
    return FloatingActionButton(
      key: const Key('newChat'),
      tooltip: 'New chat',
      onPressed: _openNewChatMenu,
      child: const Icon(Icons.add),
    );
  }

  Widget _homePages(ChatController controller, {int? selectedChatId}) {
    return TabBarView(
      controller: _tabs,
      children: [
        _ChatListBody(
          controller: controller,
          onOpenChat: _openChat,
          onRefresh: controller.load,
          selectedChatId: selectedChatId,
        ),
        _InvitationListBody(
          controller: controller,
          onAccept: _accept,
          onDecline: _decline,
          onRefresh: controller.load,
        ),
      ],
    );
  }

  Widget _wideBody(ChatController controller) {
    final selected = _summaryFor(_selectedChatId);
    final scheme = Theme.of(context).colorScheme;
    return Row(
      key: const Key('messengerWideLayout'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          key: const Key('chatListPane'),
          width: messengerChatListPaneWidth,
          child: Material(
            color: scheme.surface,
            child: Column(
              children: [
                _homeTabs(controller, scrollable: true),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _homePages(controller, selectedChatId: _selectedChatId),
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: _newChatButton(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: scheme.outlineVariant,
        ),
        Expanded(
          key: const Key('conversationPane'),
          child: ColoredBox(
            color: scheme.surface,
            child: selected == null
                ? const Center(
                    child: Text(
                      'Select a conversation',
                      key: Key('conversationEmpty'),
                    ),
                  )
                : _selectedConversation(selected),
          ),
        ),
      ],
    );
  }

  Widget _selectedConversation(ChatSummary summary) {
    final messages = MessageScope.maybeOf(context);
    final chatId = summary.chat.id;
    if (messages == null) {
      return ChatDetailScreen(
        key: ValueKey('chat-detail-$chatId'),
        controller: widget.controller,
        summary: summary,
      );
    }
    return ConversationScreen(
      key: ValueKey('conversation-$chatId'),
      embedded: true,
      chatController: widget.controller,
      summary: summary,
      messages: messages,
      selfProfileImageId: widget.profile?.profile?.profileImageId,
    );
  }
}

enum _NewChatChoice { direct, group }

class _ChatListBody extends StatelessWidget {
  const _ChatListBody({
    required this.controller,
    required this.onOpenChat,
    required this.onRefresh,
    this.selectedChatId,
  });

  final ChatController controller;
  final ValueChanged<ChatSummary> onOpenChat;
  final Future<void> Function() onRefresh;
  final int? selectedChatId;

  @override
  Widget build(BuildContext context) {
    if (controller.status == ChatStatus.loading && controller.chats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.status == ChatStatus.error && controller.chats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(controller.errorMessage ?? 'Could not load chats.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: controller.load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        if (controller.status == ChatStatus.error &&
            controller.errorMessage != null)
          _RefreshErrorBanner(
            messageKey: const Key('chatRefreshError'),
            message: controller.errorMessage!,
          ),
        Expanded(child: _chatList(context)),
      ],
    );
  }

  Widget _chatList(BuildContext context) {
    if (controller.activeChats.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(child: Text('No chats yet.', key: Key('emptyChatList'))),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        key: const Key('chatList'),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: controller.activeChats.length,
        itemBuilder: (context, index) {
          final summary = controller.activeChats[index];
          final title = chatTitle(summary);
          final bits = <String>[
            if (summary.chat.type == ChatType.group) 'Group',
            if (summary.membership.notificationsMuted) 'Muted',
          ];
          final unread = controller.unreadCountFor(summary);
          final selected = summary.chat.id == selectedChatId;
          return ListTile(
            key: Key('chatListItem-${summary.chat.id}'),
            selected: selected,
            selectedTileColor: Theme.of(context).colorScheme.secondaryContainer,
            leading: ChatListAvatar(summary: summary),
            title: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: unread > 0
                  ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )
                  : null,
            ),
            subtitle: bits.isEmpty ? null : Text(bits.join(' · ')),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (unread > 0)
                  _CountBadge(
                    key: Key('unreadBadge-${summary.chat.id}'),
                    count: unread,
                    muted: summary.membership.notificationsMuted,
                  ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => onOpenChat(summary),
          );
        },
      ),
    );
  }
}

class _InvitationListBody extends StatelessWidget {
  const _InvitationListBody({
    required this.controller,
    required this.onAccept,
    required this.onDecline,
    required this.onRefresh,
  });

  final ChatController controller;
  final ValueChanged<int> onAccept;
  final ValueChanged<int> onDecline;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (controller.status == ChatStatus.loading &&
        controller.invitations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.status == ChatStatus.error &&
        controller.invitations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.errorMessage ?? 'Could not load invitations.',
                key: const Key('invitationLoadError'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: controller.load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        if (controller.status == ChatStatus.error &&
            controller.errorMessage != null)
          _RefreshErrorBanner(
            messageKey: const Key('invitationRefreshError'),
            message: controller.errorMessage!,
          ),
        Expanded(child: _invitationList(context)),
      ],
    );
  }

  Widget _invitationList(BuildContext context) {
    if (controller.invitations.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 80),
            Center(
              child: Text(
                'No pending invitations.',
                key: Key('emptyInvitationList'),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'Invitations sent to you appear here. The sender will not see them on this tab.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        key: const Key('invitationList'),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: controller.invitations.length,
        itemBuilder: (context, index) {
          final view = controller.invitations[index];
          final id = view.invitation.id ?? index;
          return Card(
            key: Key('invitationItem-$id'),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileAvatar(
                        key: Key('invitationAvatar-$id'),
                        profileImageId: view.senderProfileImageId,
                        size: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              invitationSubtitle(view),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              view.isGroup
                                  ? 'Group invitation'
                                  : 'Direct invitation',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        key: Key('acceptInvitation-$id'),
                        onPressed: controller.actionBusy
                            ? null
                            : () => onAccept(id),
                        child: const Text('Accept'),
                      ),
                      TextButton(
                        key: Key('declineInvitation-$id'),
                        onPressed: controller.actionBusy
                            ? null
                            : () => onDecline(id),
                        child: const Text('Decline'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({super.key, required this.count, this.muted = false});

  final int count;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(
        minWidth: 22,
        minHeight: 22,
        maxHeight: 28,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: muted ? scheme.surfaceContainerHighest : scheme.primary,
        borderRadius: BorderRadius.circular(11),
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : '$count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: muted ? scheme.onSurfaceVariant : scheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RefreshErrorBanner extends StatelessWidget {
  const _RefreshErrorBanner({required this.message, required this.messageKey});

  final String message;
  final Key messageKey;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              size: 18,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                key: messageKey,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
