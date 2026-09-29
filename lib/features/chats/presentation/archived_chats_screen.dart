import 'dart:async';

import 'package:flutter/material.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/core/lifecycle/app_resume_guard.dart';
import 'package:mobile_messenger/features/chats/application/chat_controller.dart';
import 'package:mobile_messenger/features/chats/presentation/chat_labels.dart';
import 'package:mobile_messenger/features/chats/presentation/chat_list_avatar.dart';
import 'package:mobile_messenger/features/chats/presentation/open_chat.dart';

/// Archived conversations, reached from Profile.
class ArchivedChatsScreen extends StatefulWidget {
  /// Creates an [ArchivedChatsScreen].
  const ArchivedChatsScreen({
    super.key,
    required this.controller,
    this.selfProfileImageId,
  });

  final ChatController controller;
  final int? selfProfileImageId;

  @override
  State<ArchivedChatsScreen> createState() => _ArchivedChatsScreenState();
}

class _ArchivedChatsScreenState extends State<ArchivedChatsScreen>
    with WidgetsBindingObserver {
  final _resume = AppResumeGuard();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(widget.controller.load(silent: true));
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_resume.shouldRefresh(state)) {
      unawaited(_resume.run(() => widget.controller.load(silent: true)));
    }
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('archivedChatsScreen'),
      appBar: AppBar(title: const Text('Archived')),
      body: _body(),
    );
  }

  Widget _body() {
    final controller = widget.controller;
    if (controller.status == ChatStatus.loading &&
        controller.archivedChats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.status == ChatStatus.error &&
        controller.archivedChats.isEmpty) {
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

    return RefreshIndicator(
      onRefresh: () => controller.load(silent: true),
      child: _list(controller),
    );
  }

  Widget _list(ChatController controller) {
    final chats = controller.archivedChats;
    if (chats.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(
            child: Text(
              'No archived chats.',
              key: Key('emptyArchivedChatList'),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      key: const Key('archivedChatList'),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final summary = chats[index];
        final bits = <String>[
          if (summary.chat.type == ChatType.group) 'Group',
          if (summary.membership.notificationsMuted) 'Muted',
        ];
        return ListTile(
          key: Key('archivedChatListItem-${summary.chat.id}'),
          leading: ChatListAvatar(summary: summary),
          title: Text(chatTitle(summary)),
          subtitle: bits.isEmpty ? null : Text(bits.join(' · ')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => openChat(
            context: context,
            controller: controller,
            summary: summary,
            selfProfileImageId: widget.selfProfileImageId,
          ),
        );
      },
    );
  }
}
