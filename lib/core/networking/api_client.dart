import 'package:messenger_client/messenger_client.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

/// Creates the generated Serverpod client for the current platform.
///
/// The API URL comes from `--dart-define=SERVER_URL=...`, then
/// `assets/config.json`, and finally the platform localhost default.
///
/// Authentication persistence uses official [FlutterAuthSessionManager].
Future<Client> createApiClient() async {
  final serverUrl = await getServerUrl();
  final client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor();
  client.authSessionManager = FlutterAuthSessionManager();
  return client;
}
