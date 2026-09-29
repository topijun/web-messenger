import 'package:messenger_client/messenger_client.dart';

/// Server-backed device registration for this client installation.
abstract class DeviceRepository {
  /// Registers or updates this installation and refreshes last-seen.
  Future<Device> register({
    required UuidValue clientId,
    required DevicePlatform platform,
    String? pushToken,
  });

  /// Updates last-seen for this installation.
  Future<Device> touch({required UuidValue clientId});
}

/// [DeviceRepository] that talks to the generated Serverpod client.
class ServerpodDeviceRepository implements DeviceRepository {
  /// Creates a [ServerpodDeviceRepository].
  const ServerpodDeviceRepository(this._client);

  final Client _client;

  @override
  Future<Device> register({
    required UuidValue clientId,
    required DevicePlatform platform,
    String? pushToken,
  }) {
    return _client.device.register(
      clientId: clientId,
      platform: platform,
      pushToken: pushToken,
    );
  }

  @override
  Future<Device> touch({required UuidValue clientId}) {
    return _client.device.touch(clientId: clientId);
  }
}

/// Persists a stable installation id for Device upserts.
abstract class DeviceInstallationStore {
  /// Returns the existing installation id, creating one if needed.
  Future<UuidValue> getOrCreateClientId();
}

/// In-memory installation id, used when secure storage is unavailable (tests).
class MemoryDeviceInstallationStore implements DeviceInstallationStore {
  /// Creates a [MemoryDeviceInstallationStore].
  MemoryDeviceInstallationStore({UuidValue? clientId}) : _clientId = clientId;

  UuidValue? _clientId;

  @override
  Future<UuidValue> getOrCreateClientId() async {
    return _clientId ??= UuidValue.fromString(
      'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    );
  }
}
