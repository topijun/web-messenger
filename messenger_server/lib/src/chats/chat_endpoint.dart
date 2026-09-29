import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'chats.dart';

/// Authenticated chat list, membership, and group creation.
class ChatEndpoint extends Endpoint {
  static const _chats = Chats();

  @override
  bool get requireLogin => true;

  /// Lists chats the signed-in user belongs to.
  Future<List<ChatSummary>> listMine(Session session) {
    return _chats.listMine(session);
  }

  /// Lists members of a chat the signed-in user belongs to.
  Future<List<ChatMember>> listMembers(
    Session session, {
    required int chatId,
  }) {
    return _chats.listMembers(session, chatId: chatId);
  }

  /// Archives or unarchives a chat for the signed-in user.
  Future<ChatParticipant> setArchived(
    Session session, {
    required int chatId,
    required bool archived,
  }) {
    return _chats.setArchived(session, chatId: chatId, archived: archived);
  }

  /// Mutes or unmutes a chat for the signed-in user.
  Future<ChatParticipant> setMuted(
    Session session, {
    required int chatId,
    required bool notificationsMuted,
  }) {
    return _chats.setMuted(
      session,
      chatId: chatId,
      notificationsMuted: notificationsMuted,
    );
  }

  /// Creates a group chat with the signed-in user as admin.
  Future<ChatSummary> createGroup(
    Session session, {
    required String name,
  }) {
    return _chats.createGroup(session, name: name);
  }
}
