import 'package:flutter/material.dart';
import 'package:mobile_messenger/app/messenger_app.dart';
import 'package:mobile_messenger/core/networking/api_client.dart';
import 'package:mobile_messenger/core/theme/theme_controller.dart';
import 'package:mobile_messenger/features/auth/application/auth_controller.dart';
import 'package:mobile_messenger/features/auth/data/auth_repository.dart';
import 'package:mobile_messenger/features/chats/data/chat_repository.dart';
import 'package:mobile_messenger/features/device/application/device_controller.dart';
import 'package:mobile_messenger/features/messaging/data/message_repository.dart';
import 'package:mobile_messenger/features/device/data/device_repository.dart';
import 'package:mobile_messenger/features/device/data/secure_device_installation_store.dart';
import 'package:mobile_messenger/features/profile/data/profile_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final theme = ThemeController(store: SharedPreferencesThemeStore());
  await theme.load();
  final client = await createApiClient();
  final auth = AuthController(
    repository: ServerpodAuthRepository(client),
    session: ServerpodAuthSession(client),
  );
  final devices = DeviceController(
    repository: ServerpodDeviceRepository(client),
    installationStore: SecureDeviceInstallationStore(),
  );
  runApp(
    MessengerApp(
      auth: auth,
      theme: theme,
      profiles: ServerpodProfileRepository(client),
      devices: devices,
      chats: ServerpodChatRepository(client),
      messages: ServerpodMessageRepository(client),
    ),
  );
}
