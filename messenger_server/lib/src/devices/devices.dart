import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../users/current_messenger_user.dart';

/// Registers and looks up [Device] rows for the authenticated [MessengerUser].
class Devices {
  /// Creates a [Devices] instance.
  const Devices();

  /// Registers or updates the current installation and refreshes [lastSeenAt].
  Future<Device> register(
    Session session, {
    required UuidValue clientId,
    required DevicePlatform platform,
    String? pushToken,
  }) async {
    final messengerUser = await CurrentMessengerUser.require(session);
    final now = DateTime.now();
    final existing = await Device.db.findFirstRow(
      session,
      where: (t) => t.clientId.equals(clientId),
    );

    if (existing == null) {
      return Device.db.insertRow(
        session,
        Device(
          userId: messengerUser.id!,
          clientId: clientId,
          platform: platform,
          pushToken: pushToken,
          lastSeenAt: now,
        ),
      );
    }

    return Device.db.updateRow(
      session,
      existing.copyWith(
        userId: messengerUser.id,
        platform: platform,
        pushToken: pushToken,
        lastSeenAt: now,
      ),
    );
  }

  /// Updates [lastSeenAt] for the current user's installation.
  Future<Device> touch(
    Session session, {
    required UuidValue clientId,
  }) async {
    final messengerUser = await CurrentMessengerUser.require(session);
    final device = await Device.db.findFirstRow(
      session,
      where: (t) => t.clientId.equals(clientId),
    );
    if (device == null || device.userId != messengerUser.id) {
      throw MessengerDeviceNotFoundException(clientId: clientId);
    }

    return Device.db.updateRow(
      session,
      device.copyWith(lastSeenAt: DateTime.now()),
    );
  }

  /// Returns devices belonging to the signed-in user.
  Future<List<Device>> listMine(Session session) async {
    final messengerUser = await CurrentMessengerUser.require(session);
    return Device.db.find(
      session,
      where: (t) => t.userId.equals(messengerUser.id),
      orderBy: (t) => t.lastSeenAt,
      orderDescending: true,
    );
  }
}
