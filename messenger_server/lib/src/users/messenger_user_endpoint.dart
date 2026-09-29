import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../chats/chats.dart';
import '../generated/protocol.dart';
import 'messenger_users.dart';

/// Authenticated access to the current user's [MessengerUser].
class MessengerUserEndpoint extends Endpoint {
  static const _messengerUsers = MessengerUsers();
  static const _chats = Chats();

  @override
  bool get requireLogin => true;

  /// Returns the [MessengerUser] for the signed-in [AuthUser], if one exists.
  Future<MessengerUser?> get(Session session) async {
    final authUserId = session.authenticated!.authUserId;
    return _messengerUsers.findByAuthUserId(session, authUserId: authUserId);
  }

  /// Looks up a Messenger user by username, ignoring case.
  ///
  /// Returns null when no matching account exists.
  Future<MessengerUser?> lookupByUsername(
    Session session, {
    required String username,
  }) {
    return _messengerUsers.findByUsername(session, username: username);
  }

  /// Finds a contact by exact username or email for the invitation flow.
  ///
  /// The server treats a query containing `@` as email and otherwise as
  /// username. Returns null when no registered user matches.
  Future<ContactSearchResult?> searchContact(
    Session session, {
    required String query,
  }) {
    return _chats.searchContact(session, query: query);
  }
}
