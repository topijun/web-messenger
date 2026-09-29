import 'dart:async';

import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/features/chats/data/chat_repository.dart';

import 'auth_fakes.dart';

ChatSummary testDirectChat({
  int id = 1,
  String otherUsername = 'Bob',
  int? otherProfileImageId,
  bool archived = false,
  bool notificationsMuted = false,
  ChatParticipantRole role = ChatParticipantRole.member,
  int unreadCount = 0,
  DateTime? lastMessageAt,
}) {
  return ChatSummary(
    chat: Chat(id: id, type: ChatType.direct, lastMessageAt: lastMessageAt),
    membership: ChatParticipant(
      id: id,
      chatId: id,
      userId: 1,
      role: role,
      archived: archived,
      notificationsMuted: notificationsMuted,
    ),
    otherUsernames: [otherUsername],
    otherAvatars: [
      UserAvatarRef(
        username: otherUsername,
        profileImageId: otherProfileImageId,
      ),
    ],
    unreadCount: unreadCount,
  );
}

ChatSummary testGroupChat({
  int id = 2,
  String name = 'Weekend trip',
  bool archived = false,
  bool notificationsMuted = false,
  ChatParticipantRole role = ChatParticipantRole.admin,
  int unreadCount = 0,
  DateTime? lastMessageAt,
  List<UserAvatarRef>? otherAvatars,
}) {
  final avatars =
      otherAvatars ??
      [UserAvatarRef(username: 'Bob')];
  return ChatSummary(
    chat: Chat(
      id: id,
      type: ChatType.group,
      name: name,
      lastMessageAt: lastMessageAt,
    ),
    membership: ChatParticipant(
      id: id * 10,
      chatId: id,
      userId: 1,
      role: role,
      archived: archived,
      notificationsMuted: notificationsMuted,
    ),
    otherUsernames: [for (final avatar in avatars) avatar.username],
    otherAvatars: avatars,
    unreadCount: unreadCount,
  );
}

ChatInvitationView testInvitation({
  int id = 10,
  String senderUsername = 'Alice',
  int? senderProfileImageId,
  bool isGroup = false,
  String? chatName,
  int? chatId,
}) {
  return ChatInvitationView(
    invitation: ChatInvitation(
      id: id,
      chatId: isGroup ? (chatId ?? 5) : chatId,
      senderId: 2,
      receiverId: 1,
      status: ChatInvitationStatus.pending,
    ),
    senderUsername: senderUsername,
    senderProfileImageId: senderProfileImageId,
    receiverUsername: 'Topi.J',
    chatName: chatName,
    isGroup: isGroup,
  );
}

ChatMember testChatMember({
  int userId = 1,
  String username = 'Topi.J',
  int? profileImageId,
  ChatParticipantRole role = ChatParticipantRole.member,
}) {
  return ChatMember(
    userId: userId,
    username: username,
    profileImageId: profileImageId,
    role: role,
    joinedAt: DateTime.utc(2026, 9, 18),
  );
}

class FakeChatRepository implements ChatRepository {
  FakeChatRepository({
    List<ChatSummary>? chats,
    List<ChatInvitationView>? invitations,
    List<ChatMember>? members,
    this.loadError,
    this.chatsLoadError,
    this.invitationsLoadError,
    this.actionError,
    this.chatsCompleter,
    this.lookupUser,
    this.searchResult,
    this.searchError,
    this.searchCompleter,
  }) : chats = List<ChatSummary>.from(chats ?? const []),
       invitations = List<ChatInvitationView>.from(invitations ?? const []),
       members = List<ChatMember>.from(
         members ??
             [
               testChatMember(role: ChatParticipantRole.admin),
               testChatMember(userId: 2, username: 'Bob'),
             ],
       );

  List<ChatSummary> chats;
  List<ChatInvitationView> invitations;
  List<ChatMember> members;
  Object? loadError;
  Object? chatsLoadError;
  Object? invitationsLoadError;
  Object? actionError;
  Completer<List<ChatSummary>>? chatsCompleter;
  MessengerUser? lookupUser;
  ContactSearchResult? searchResult;
  Object? searchError;
  Completer<ContactSearchResult?>? searchCompleter;
  Completer<void>? acceptCompleter;

  int listMineCalls = 0;
  int listPendingMineCalls = 0;
  int listMembersCalls = 0;
  String? lastSearchQuery;
  String? lastInvitedUsername;
  String? lastCreatedGroupName;
  String? lastGroupInviteUsername;
  int? lastGroupInviteChatId;
  int? lastAcceptedId;
  int? lastDeclinedId;
  int? lastArchivedChatId;
  bool? lastArchivedValue;
  int? lastMutedChatId;
  bool? lastMutedValue;

  @override
  Future<List<ChatSummary>> listMine() async {
    listMineCalls += 1;
    if (chatsCompleter != null) {
      return chatsCompleter!.future;
    }
    if (loadError != null) {
      throw loadError!;
    }
    if (chatsLoadError != null) {
      throw chatsLoadError!;
    }
    return List<ChatSummary>.from(chats);
  }

  @override
  Future<List<ChatInvitationView>> listPendingMine() async {
    listPendingMineCalls += 1;
    if (loadError != null) {
      throw loadError!;
    }
    if (invitationsLoadError != null) {
      throw invitationsLoadError!;
    }
    return List<ChatInvitationView>.from(invitations);
  }

  @override
  Future<List<ChatMember>> listMembers({required int chatId}) async {
    listMembersCalls += 1;
    if (loadError != null) {
      throw loadError!;
    }
    return List<ChatMember>.from(members);
  }

  @override
  Future<ChatParticipant> setArchived({
    required int chatId,
    required bool archived,
  }) async {
    lastArchivedChatId = chatId;
    lastArchivedValue = archived;
    if (actionError != null) {
      throw actionError!;
    }
    return _updateMembership(
      chatId,
      (membership) => membership.copyWith(archived: archived),
    );
  }

  @override
  Future<ChatParticipant> setMuted({
    required int chatId,
    required bool notificationsMuted,
  }) async {
    lastMutedChatId = chatId;
    lastMutedValue = notificationsMuted;
    if (actionError != null) {
      throw actionError!;
    }
    return _updateMembership(
      chatId,
      (membership) =>
          membership.copyWith(notificationsMuted: notificationsMuted),
    );
  }

  @override
  Future<ChatSummary> createGroup({required String name}) async {
    lastCreatedGroupName = name;
    if (actionError != null) {
      throw actionError!;
    }
    final created = testGroupChat(id: 100 + chats.length, name: name);
    chats = [...chats, created];
    return created;
  }

  @override
  Future<ChatInvitationView> inviteDirect({required String username}) async {
    lastInvitedUsername = username;
    if (actionError != null) {
      throw actionError!;
    }
    return testInvitation(id: 99, senderUsername: 'Topi.J');
  }

  @override
  Future<ChatInvitationView> inviteToGroup({
    required int chatId,
    required String username,
  }) async {
    lastGroupInviteChatId = chatId;
    lastGroupInviteUsername = username;
    if (actionError != null) {
      throw actionError!;
    }
    if (!members.any(
      (member) => member.username.toLowerCase() == username.toLowerCase(),
    )) {
      members = [
        ...members,
        testChatMember(userId: 90 + members.length, username: username),
      ];
    }
    return testInvitation(
      id: 98,
      senderUsername: 'Topi.J',
      isGroup: true,
      chatId: chatId,
    );
  }

  @override
  Future<ChatSummary> accept({required int invitationId}) async {
    lastAcceptedId = invitationId;
    if (acceptCompleter != null) {
      await acceptCompleter!.future;
    }
    if (actionError != null) {
      throw actionError!;
    }
    ChatInvitationView? accepted;
    final remaining = <ChatInvitationView>[];
    for (final invitation in invitations) {
      if (invitation.invitation.id == invitationId) {
        accepted = invitation;
      } else {
        remaining.add(invitation);
      }
    }
    invitations = remaining;
    final created = accepted != null && accepted.isGroup
        ? testGroupChat(
            id: 50 + invitationId,
            name: accepted.chatName ?? 'Group',
          )
        : testDirectChat(
            id: 50 + invitationId,
            otherUsername: accepted?.senderUsername ?? 'Alice',
          );
    chats = [...chats, created];
    return created;
  }

  @override
  Future<ChatInvitationView> decline({required int invitationId}) async {
    lastDeclinedId = invitationId;
    if (actionError != null) {
      throw actionError!;
    }
    ChatInvitationView? declined;
    final remaining = <ChatInvitationView>[];
    for (final invitation in invitations) {
      if (invitation.invitation.id == invitationId) {
        declined = invitation;
      } else {
        remaining.add(invitation);
      }
    }
    invitations = remaining;
    return declined ?? testInvitation(id: invitationId);
  }

  @override
  Future<MessengerUser?> lookupByUsername({required String username}) async {
    if (actionError != null) {
      throw actionError!;
    }
    if (lookupUser != null &&
        lookupUser!.username.toLowerCase() == username.toLowerCase()) {
      return lookupUser;
    }
    return null;
  }

  @override
  Future<ContactSearchResult?> searchContact({required String query}) async {
    lastSearchQuery = query;
    if (searchCompleter != null) {
      return searchCompleter!.future;
    }
    if (searchError != null) {
      throw searchError!;
    }
    return searchResult;
  }

  ChatParticipant _updateMembership(
    int chatId,
    ChatParticipant Function(ChatParticipant membership) update,
  ) {
    ChatParticipant? updated;
    chats = [
      for (final summary in chats)
        if (summary.chat.id == chatId)
          ChatSummary(
            chat: summary.chat,
            membership: updated = update(summary.membership),
            otherUsernames: summary.otherUsernames,
            otherAvatars: summary.otherAvatars,
            unreadCount: summary.unreadCount,
          )
        else
          summary,
    ];
    return updated ??
        ChatParticipant(
          chatId: chatId,
          userId: 1,
          role: ChatParticipantRole.member,
        );
  }
}

MessengerUser testLookupUser({String username = 'Bob'}) {
  return testMessengerUser(username: username);
}

ContactSearchResult testContact({
  String username = 'Bob',
  ContactSearchRelation relation = ContactSearchRelation.none,
  int? profileImageId,
}) {
  return ContactSearchResult(
    username: username,
    relation: relation,
    profileImageId: profileImageId,
  );
}
