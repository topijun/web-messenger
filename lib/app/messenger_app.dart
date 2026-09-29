import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_messenger/core/lifecycle/app_resume_guard.dart';
import 'package:mobile_messenger/core/theme/app_theme.dart';
import 'package:mobile_messenger/core/theme/theme_controller.dart';
import 'package:mobile_messenger/core/theme/theme_scope.dart';
import 'package:mobile_messenger/features/auth/application/auth_controller.dart';
import 'package:mobile_messenger/features/auth/presentation/auth_gate.dart';
import 'package:mobile_messenger/features/auth/presentation/auth_scope.dart';
import 'package:mobile_messenger/features/chats/data/chat_repository.dart';
import 'package:mobile_messenger/features/chats/presentation/chat_scope.dart';
import 'package:mobile_messenger/features/device/application/device_controller.dart';
import 'package:mobile_messenger/features/messaging/data/message_repository.dart';
import 'package:mobile_messenger/features/messaging/presentation/message_scope.dart';
import 'package:mobile_messenger/features/profile/data/profile_image_store.dart';
import 'package:mobile_messenger/features/profile/data/profile_repository.dart';
import 'package:mobile_messenger/features/profile/presentation/profile_scope.dart';

/// Root widget for Mobile Messenger.
class MessengerApp extends StatefulWidget {
  /// Creates a [MessengerApp].
  const MessengerApp({
    super.key,
    required this.auth,
    this.theme,
    this.profiles,
    this.devices,
    this.chats,
    this.messages,
  });

  final AuthController auth;
  final ThemeController? theme;
  final ProfileRepository? profiles;
  final DeviceController? devices;
  final ChatRepository? chats;
  final MessageRepository? messages;

  @override
  State<MessengerApp> createState() => _MessengerAppState();
}

class _MessengerAppState extends State<MessengerApp>
    with WidgetsBindingObserver {
  final _resume = AppResumeGuard();
  ThemeController? _ownedTheme;
  ProfileImageStore? _profileImages;
  var _deviceRegistered = false;

  ThemeController get _theme {
    return widget.theme ?? _ownedTheme!;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.theme == null) {
      _ownedTheme = ThemeController(store: MemoryThemePreferenceStore());
    }
    _theme.addListener(_onThemeChanged);
    widget.auth.addListener(_onAuthChanged);
    widget.auth.restoreSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _theme.removeListener(_onThemeChanged);
    _ownedTheme?.dispose();
    widget.auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_resume.shouldRefresh(state)) {
      return;
    }
    unawaited(_resume.run(widget.auth.reconcileSession));
  }

  void _onAuthChanged() {
    if (widget.auth.state.isAuthenticated) {
      if (!_deviceRegistered) {
        _deviceRegistered = true;
        widget.devices?.registerCurrent();
      }
    } else {
      _deviceRegistered = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget app = AuthScope(
      controller: widget.auth,
      child: ThemeScope(
        controller: _theme,
        child: MaterialApp(
          title: 'Messenger',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _theme.themeMode,
          home: const AuthGate(),
        ),
      ),
    );

    final profiles = widget.profiles;
    if (profiles != null) {
      _profileImages ??= ProfileImageStore(profiles);
      app = ProfileScope(
        repository: profiles,
        images: _profileImages!,
        child: app,
      );
    }
    final chats = widget.chats;
    if (chats != null) {
      app = ChatScope(repository: chats, child: app);
    }
    final messages = widget.messages;
    if (messages != null) {
      app = MessageScope(repository: messages, child: app);
    }
    return app;
  }
}
