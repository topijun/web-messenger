import 'package:flutter/material.dart';
import 'package:mobile_messenger/features/auth/presentation/auth_scope.dart';
import 'package:mobile_messenger/features/chats/application/chat_controller.dart';
import 'package:mobile_messenger/features/chats/data/chat_repository.dart';
import 'package:mobile_messenger/features/chats/presentation/chat_scope.dart';
import 'package:mobile_messenger/features/chats/presentation/chats_home_screen.dart';
import 'package:mobile_messenger/features/messaging/presentation/message_scope.dart';
import 'package:mobile_messenger/features/profile/application/profile_controller.dart';
import 'package:mobile_messenger/features/profile/presentation/profile_scope.dart';
import 'package:mobile_messenger/features/profile/presentation/profile_screen.dart';

/// Authenticated home: chat UI when [ChatScope] is present, otherwise a
/// signed-in placeholder used by authentication tests.
class HomeScreen extends StatelessWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = ChatScope.maybeOf(context);
    if (chats != null) {
      return _ChatHomeHost(repository: chats);
    }
    return const _SignedInPlaceholder();
  }
}

class _ChatHomeHost extends StatefulWidget {
  const _ChatHomeHost({required this.repository});

  final ChatRepository repository;

  @override
  State<_ChatHomeHost> createState() => _ChatHomeHostState();
}

class _ChatHomeHostState extends State<_ChatHomeHost> {
  ChatController? _controller;
  ProfileController? _profile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= ChatController(
      repository: widget.repository,
      watch: () => MessageScope.maybeOf(context)?.watch(),
    )..load();
    final profiles = ProfileScope.maybeOf(context);
    if (_profile == null && profiles != null) {
      _profile = ProfileController(
        repository: profiles,
        username: AuthScope.of(context).state.username ?? 'Unknown',
      )..load();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _profile?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChatHomeScreen(
      controller: _controller!,
      profile: _profile,
    );
  }
}

class _SignedInPlaceholder extends StatelessWidget {
  const _SignedInPlaceholder();

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final username = auth.state.username;
    final profiles = ProfileScope.maybeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messenger'),
        actions: [
          if (profiles != null)
            IconButton(
              tooltip: 'Profile',
              icon: const Icon(Icons.person_outline),
              onPressed: () async {
                final controller = ProfileController(
                  repository: profiles,
                  username: username ?? 'Unknown',
                );
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ProfileScreen(controller: controller),
                  ),
                );
                controller.dispose();
              },
            ),
          TextButton(
            onPressed: auth.state.isBusy ? null : auth.logout,
            child: const Text('Log out'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                username == null
                    ? 'You are signed in.'
                    : 'Signed in as $username',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Chats will appear here in a later phase.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
