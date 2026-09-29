import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';
import 'package:mobile_messenger/features/device/data/device_repository.dart';

/// Stores the Device [clientId] in official Flutter secure storage.
class SecureDeviceInstallationStore implements DeviceInstallationStore {
  /// Creates a [SecureDeviceInstallationStore].
  SecureDeviceInstallationStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'messenger.device.clientId';

  final FlutterSecureStorage _storage;

  @override
  Future<UuidValue> getOrCreateClientId() async {
    final existing = await _storage.read(key: _key);
    if (existing != null && existing.isNotEmpty) {
      return UuidValue.fromString(existing);
    }
    final created = const Uuid().v4obj();
    await _storage.write(key: _key, value: created.uuid);
    return created;
  }
}
