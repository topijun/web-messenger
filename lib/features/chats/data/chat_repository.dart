import 'package:messenger_client/messenger_client.dart';

/// Server-backed chat list, membership, and invitation operations.
abstract class ChatRepository {
  /// Lists chats the signed-in user belongs to.
  Future<List<ChatSummary>> listMine();

  /// Lists members of a chat the signed-in user belongs to.
  Future<List<ChatMember>> listMembers({required int chatId});

  /// Archives or unarchives a chat for the signed-in user.
  Future<ChatParticipant> setArchived({
    required int chatId,
    required bool archived,
  });

  /// Mutes or unmutes notifications for a chat for the signed-in user.
  Future<ChatParticipant> setMuted({
    required int chatId,
    required bool notificationsMuted,
  });

  /// Creates a group chat with the signed-in user as admin.
  Future<ChatSummary> createGroup({required String name});

  /// Invites [username] to a new direct chat.
  Future<ChatInvitationView> inviteDirect({required String username});

  /// Invites [username] to an existing group. Caller must be an admin.
  Future<ChatInvitationView> inviteToGroup({
    required int chatId,
    required String username,
  });

  /// Pending invitations addressed to the signed-in user.
  Future<List<ChatInvitationView>> listPendingMine();

  /// Accepts an invitation addressed to the signed-in user.
  Future<ChatSummary> accept({required int invitationId});

  /// Declines an invitation addressed to the signed-in user.
  Future<ChatInvitationView> decline({required int invitationId});

  /// Looks up a Messenger user by username, ignoring case.
  Future<MessengerUser?> lookupByUsername({required String username});

  /// Finds a contact by exact username or email.
  Future<ContactSearchResult?> searchContact({required String query});
}

/// [ChatRepository] that talks to the generated Serverpod client.
class ServerpodChatRepository implements ChatRepository {
  /// Creates a [ServerpodChatRepository].
  const ServerpodChatRepository(this._client);

  final Client _client;

  @override
  Future<List<ChatSummary>> listMine() => _client.chat.listMine();

  @override
  Future<List<ChatMember>> listMembers({required int chatId}) {
    return _client.chat.listMembers(chatId: chatId);
  }

  @override
  Future<ChatParticipant> setArchived({
    required int chatId,
    required bool archived,
  }) {
    return _client.chat.setArchived(chatId: chatId, archived: archived);
  }

  @override
  Future<ChatParticipant> setMuted({
    required int chatId,
    required bool notificationsMuted,
  }) {
    return _client.chat.setMuted(
      chatId: chatId,
      notificationsMuted: notificationsMuted,
    );
  }

  @override
  Future<ChatSummary> createGroup({required String name}) {
    return _client.chat.createGroup(name: name);
  }

  @override
  Future<ChatInvitationView> inviteDirect({required String username}) {
    return _client.chatInvitation.inviteDirect(username: username);
  }

  @override
  Future<ChatInvitationView> inviteToGroup({
    required int chatId,
    required String username,
  }) {
    return _client.chatInvitation.inviteToGroup(
      chatId: chatId,
      username: username,
    );
  }

  @override
  Future<List<ChatInvitationView>> listPendingMine() {
    return _client.chatInvitation.listPendingMine();
  }

  @override
  Future<ChatSummary> accept({required int invitationId}) {
    return _client.chatInvitation.accept(invitationId: invitationId);
  }

  @override
  Future<ChatInvitationView> decline({required int invitationId}) {
    return _client.chatInvitation.decline(invitationId: invitationId);
  }

  @override
  Future<MessengerUser?> lookupByUsername({required String username}) {
    return _client.messengerUser.lookupByUsername(username: username);
  }

  @override
  Future<ContactSearchResult?> searchContact({required String query}) {
    return _client.messengerUser.searchContact(query: query);
  }
}
