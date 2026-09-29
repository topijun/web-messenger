import 'package:flutter/foundation.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/features/device/data/device_repository.dart';

/// Registers this client installation after Serverpod authentication.
class DeviceController {
  /// Creates a [DeviceController].
  DeviceController({
    required DeviceRepository repository,
    required DeviceInstallationStore installationStore,
  }) : _repository = repository,
       _installationStore = installationStore;

  final DeviceRepository _repository;
  final DeviceInstallationStore _installationStore;

  /// Registers or updates the current installation. Errors are ignored so Home
  /// still loads if the device call fails.
  Future<void> registerCurrent() async {
    try {
      final clientId = await _installationStore.getOrCreateClientId();
      await _repository.register(
        clientId: clientId,
        platform: currentDevicePlatform(),
      );
    } catch (_) {
      // Device registration is not required to use the authenticated app.
    }
  }

  /// Refreshes last-seen for this installation.
  Future<void> touchCurrent() async {
    try {
      final clientId = await _installationStore.getOrCreateClientId();
      await _repository.touch(clientId: clientId);
    } catch (_) {}
  }
}

/// Maps the Flutter platform to the Messenger [DevicePlatform] enum.
DevicePlatform currentDevicePlatform() {
  if (kIsWeb) {
    return DevicePlatform.web;
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS => DevicePlatform.ios,
    TargetPlatform.android => DevicePlatform.android,
    _ => DevicePlatform.web,
  };
}
