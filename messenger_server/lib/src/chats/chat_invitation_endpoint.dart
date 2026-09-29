import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'chats.dart';

/// Authenticated chat invitations for the signed-in user.
class ChatInvitationEndpoint extends Endpoint {
  static const _chats = Chats();

  @override
  bool get requireLogin => true;

  /// Invites [username] to a new direct chat.
  Future<ChatInvitationView> inviteDirect(
    Session session, {
    required String username,
  }) {
    return _chats.inviteDirect(session, username: username);
  }

  /// Invites [username] to an existing group. Caller must be an admin.
  Future<ChatInvitationView> inviteToGroup(
    Session session, {
    required int chatId,
    required String username,
  }) {
    return _chats.inviteToGroup(
      session,
      chatId: chatId,
      username: username,
    );
  }

  /// Pending invitations addressed to the signed-in user.
  Future<List<ChatInvitationView>> listPendingMine(Session session) {
    return _chats.listPendingMine(session);
  }

  /// Accepts an invitation addressed to the signed-in user.
  Future<ChatSummary> accept(
    Session session, {
    required int invitationId,
  }) {
    return _chats.acceptInvitation(session, invitationId: invitationId);
  }

  /// Declines an invitation addressed to the signed-in user.
  Future<ChatInvitationView> decline(
    Session session, {
    required int invitationId,
  }) {
    return _chats.declineInvitation(session, invitationId: invitationId);
  }
}
