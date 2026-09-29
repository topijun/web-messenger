import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'devices.dart';

/// Authenticated access to the current user's [Device] installations.
class DeviceEndpoint extends Endpoint {
  static const _devices = Devices();

  @override
  bool get requireLogin => true;

  /// Registers or updates this client installation.
  Future<Device> register(
    Session session, {
    required UuidValue clientId,
    required DevicePlatform platform,
    String? pushToken,
  }) {
    return _devices.register(
      session,
      clientId: clientId,
      platform: platform,
      pushToken: pushToken,
    );
  }

  /// Updates last-seen for this client installation.
  Future<Device> touch(
    Session session, {
    required UuidValue clientId,
  }) {
    return _devices.touch(session, clientId: clientId);
  }

  /// Lists installations belonging to the signed-in user.
  Future<List<Device>> listMine(Session session) {
    return _devices.listMine(session);
  }
}
