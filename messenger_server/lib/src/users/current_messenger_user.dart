import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';
import 'messenger_users.dart';

/// Resolves the signed-in [MessengerUser] from the Serverpod session.
class CurrentMessengerUser {
  static const _messengerUsers = MessengerUsers();

  /// Returns the [MessengerUser] for the authenticated session.
  ///
  /// Throws [MessengerAccountRequiredException] if none exists.
  static Future<MessengerUser> require(
    Session session, {
    Transaction? transaction,
  }) async {
    final authUserId = session.authenticated!.authUserId;
    final messengerUser = await _messengerUsers.findByAuthUserId(
      session,
      authUserId: authUserId,
      transaction: transaction,
    );
    if (messengerUser == null) {
      throw MessengerAccountRequiredException(authUserId: authUserId);
    }
    return messengerUser;
  }
}
