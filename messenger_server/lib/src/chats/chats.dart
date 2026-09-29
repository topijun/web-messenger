import 'package:serverpod/serverpod.dart' hide Message;

import '../encryption/encryption_service.dart';
import '../generated/protocol.dart';
import '../messages/messages.dart';
import '../profiles/profiles.dart';
import '../users/current_messenger_user.dart';
import '../users/messenger_users.dart';

/// Direct chats, group chats, membership, and invitations.
class Chats {
  static const _messengerUsers = MessengerUsers();
  static const _profiles = Profiles();
  static const maxGroupNameLength = 50;

  /// Creates a [Chats] instance.
  const Chats();

  /// Lists chats the current user belongs to.
  ///
  /// Ordered by [Chat.lastMessageAt] descending, nulls last, then id.
  Future<List<ChatSummary>> listMine(Session session) async {
    final me = await CurrentMessengerUser.require(session);
    final memberships = await ChatParticipant.db.find(
      session,
      where: (t) => t.userId.equals(me.id),
    );
    if (memberships.isEmpty) {
      return [];
    }

    final membershipByChatId = {
      for (final membership in memberships) membership.chatId: membership,
    };
    final chats = await Chat.db.find(
      session,
      where: (t) => t.id.inSet(membershipByChatId.keys.toSet()),
    );
    chats.sort(_compareChats);

    final participants = await ChatParticipant.db.find(
      session,
      where: (t) => t.chatId.inSet(membershipByChatId.keys.toSet()),
    );
    final userIds = participants.map((row) => row.userId).toSet();
    final users = await MessengerUser.db.find(
      session,
      where: (t) => t.id.inSet(userIds),
    );
    final usernameById = {
      for (final user in users) user.id!: user.username,
    };

    final otherIdsByChatId = <int, List<int>>{};
    for (final participant in participants) {
      if (participant.userId == me.id) {
        continue;
      }
      otherIdsByChatId
          .putIfAbsent(participant.chatId, () => [])
          .add(participant.userId);
    }
    for (final ids in otherIdsByChatId.values) {
      ids.sort(
        (a, b) => (usernameById[a] ?? '').toLowerCase().compareTo(
          (usernameById[b] ?? '').toLowerCase(),
        ),
      );
    }

    final imageIdByUserId = await _profiles.imageIdsByUserIds(
      session,
      otherIdsByChatId.values.expand((ids) => ids),
    );

    final unreadByChatId = await _unreadCounts(
      session,
      userId: me.id!,
      chatIds: membershipByChatId.keys.toSet(),
    );

    return [
      for (final chat in chats)
        ChatSummary(
          chat: await _chatForClient(session, chat),
          membership: membershipByChatId[chat.id]!,
          otherUsernames: _usernamesFor(
            otherIdsByChatId[chat.id] ?? const [],
            usernameById,
          ),
          otherAvatars: _avatarsFor(
            otherIdsByChatId[chat.id] ?? const [],
            usernameById,
            imageIdByUserId,
          ),
          unreadCount: unreadByChatId[chat.id] ?? 0,
        ),
    ];
  }

  /// Lists members of [chatId]. Caller must already be a participant.
  Future<List<ChatMember>> listMembers(
    Session session, {
    required int chatId,
  }) async {
    final me = await CurrentMessengerUser.require(session);
    await _requireMembership(session, chatId: chatId, userId: me.id!);

    final participants = await ChatParticipant.db.find(
      session,
      where: (t) => t.chatId.equals(chatId),
    );
    final users = await MessengerUser.db.find(
      session,
      where: (t) => t.id.inSet(participants.map((row) => row.userId).toSet()),
    );
    final usernameById = {
      for (final user in users) user.id!: user.username,
    };

    final imageIdByUserId = await _profiles.imageIdsByUserIds(
      session,
      participants.map((row) => row.userId),
    );

    return [
      for (final participant in participants)
        ChatMember(
          userId: participant.userId,
          username: usernameById[participant.userId] ?? 'Unknown',
          profileImageId: imageIdByUserId[participant.userId],
          role: participant.role,
          joinedAt: participant.joinedAt,
        ),
    ];
  }

  /// Archives or unarchives a chat for the current user only.
  Future<ChatParticipant> setArchived(
    Session session, {
    required int chatId,
    required bool archived,
  }) {
    return _updateMembership(
      session,
      chatId: chatId,
      update: (membership) => membership.copyWith(archived: archived),
    );
  }

  /// Mutes or unmutes notifications for the current user only.
  Future<ChatParticipant> setMuted(
    Session session, {
    required int chatId,
    required bool notificationsMuted,
  }) {
    return _updateMembership(
      session,
      chatId: chatId,
      update: (membership) =>
          membership.copyWith(notificationsMuted: notificationsMuted),
    );
  }

  /// Creates a group chat and makes the current user admin.
  Future<ChatSummary> createGroup(
    Session session, {
    required String name,
  }) async {
    final groupName = name.trim();
    if (groupName.isEmpty) {
      throw MessengerInvalidChatInputException(
        field: 'name',
        message: 'Group name is required.',
      );
    }
    if (groupName.length > maxGroupNameLength) {
      throw MessengerInvalidChatInputException(
        field: 'name',
        message: 'Group name must be at most $maxGroupNameLength characters.',
      );
    }

    final me = await CurrentMessengerUser.require(session);
    return DatabaseUtil.runInTransactionOrSavepoint(session.db, null, (
      transaction,
    ) async {
      final chat = await Chat.db.insertRow(
        session,
        Chat(
          type: ChatType.group,
          name: await EncryptionService.of(session).encrypt(groupName),
        ),
        transaction: transaction,
      );
      final membership = await ChatParticipant.db.insertRow(
        session,
        ChatParticipant(
          chatId: chat.id!,
          userId: me.id!,
          role: ChatParticipantRole.admin,
        ),
        transaction: transaction,
      );
      return ChatSummary(
        chat: await _chatForClient(session, chat),
        membership: membership,
        otherUsernames: const [],
        otherAvatars: const [],
        unreadCount: 0,
      );
    });
  }

  /// Finds a registered user by username or email for the invitation flow.
  ///
  /// Returns null when nothing matches. The result is invitation metadata only
  /// (username + relation). It does not include auth ids, email, or secrets.
  Future<ContactSearchResult?> searchContact(
    Session session, {
    required String query,
  }) async {
    final me = await CurrentMessengerUser.require(session);
    final other = await _messengerUsers.findByQuery(session, query: query);
    if (other == null) {
      return null;
    }
    final imageIds = await _profiles.imageIdsByUserIds(session, [other.id!]);
    final profileImageId = imageIds[other.id!];
    if (other.id == me.id) {
      return ContactSearchResult(
        username: other.username,
        relation: ContactSearchRelation.self,
        profileImageId: profileImageId,
      );
    }

    return DatabaseUtil.runInTransactionOrSavepoint(session.db, null, (
      transaction,
    ) async {
      final existingChat = await _findDirectChat(
        session,
        userIdA: me.id!,
        userIdB: other.id!,
        transaction: transaction,
      );
      if (existingChat != null) {
        return ContactSearchResult(
          username: other.username,
          relation: ContactSearchRelation.chatting,
          profileImageId: profileImageId,
        );
      }

      final pending = await _findPendingDirectInvitation(
        session,
        userIdA: me.id!,
        userIdB: other.id!,
        transaction: transaction,
      );
      if (pending != null) {
        return ContactSearchResult(
          username: other.username,
          relation: pending.senderId == me.id
              ? ContactSearchRelation.invitationSent
              : ContactSearchRelation.invitationReceived,
          profileImageId: profileImageId,
        );
      }

      return ContactSearchResult(
        username: other.username,
        relation: ContactSearchRelation.none,
        profileImageId: profileImageId,
      );
    });
  }

  /// Sends a direct-chat invitation. No chat is created until accept.
  Future<ChatInvitationView> inviteDirect(
    Session session, {
    required String username,
  }) async {
    final me = await CurrentMessengerUser.require(session);
    final other = await _requireUserByUsername(session, username);
    if (other.id == me.id) {
      throw MessengerSelfInvitationException();
    }

    final view = await DatabaseUtil.runInTransactionOrSavepoint(
      session.db,
      null,
      (
        transaction,
      ) async {
        final existingChat = await _findDirectChat(
          session,
          userIdA: me.id!,
          userIdB: other.id!,
          transaction: transaction,
        );
        if (existingChat != null) {
          throw MessengerDirectChatAlreadyExistsException(
            username: other.username,
          );
        }

        final pending = await _findPendingDirectInvitation(
          session,
          userIdA: me.id!,
          userIdB: other.id!,
          transaction: transaction,
        );
        if (pending != null) {
          throw MessengerDuplicateInvitationException(username: other.username);
        }

        final invitation = await ChatInvitation.db.insertRow(
          session,
          ChatInvitation(
            senderId: me.id!,
            receiverId: other.id!,
            status: ChatInvitationStatus.pending,
          ),
          transaction: transaction,
        );
        return ChatInvitationView(
          invitation: invitation,
          senderUsername: me.username,
          senderProfileImageId: (await _profiles.imageIdsByUserIds(
            session,
            [me.id!],
            transaction: transaction,
          ))[me.id!],
          receiverUsername: other.username,
          isGroup: false,
        );
      },
    );
    await _notifyInvitation(session, view);
    return view;
  }

  /// Admin-only invitation to an existing group chat.
  Future<ChatInvitationView> inviteToGroup(
    Session session, {
    required int chatId,
    required String username,
  }) async {
    final me = await CurrentMessengerUser.require(session);
    final other = await _requireUserByUsername(session, username);
    if (other.id == me.id) {
      throw MessengerSelfInvitationException();
    }

    final view = await DatabaseUtil.runInTransactionOrSavepoint(
      session.db,
      null,
      (
        transaction,
      ) async {
        final chat = await _requireGroupAdmin(
          session,
          chatId: chatId,
          userId: me.id!,
          transaction: transaction,
        );

        final alreadyMember = await ChatParticipant.db.findFirstRow(
          session,
          where: (t) => t.chatId.equals(chatId) & t.userId.equals(other.id),
          transaction: transaction,
        );
        if (alreadyMember != null) {
          throw MessengerAlreadyChatParticipantException(
            username: other.username,
          );
        }

        final pending = await ChatInvitation.db.findFirstRow(
          session,
          where: (t) =>
              t.chatId.equals(chatId) &
              t.receiverId.equals(other.id) &
              t.status.equals(ChatInvitationStatus.pending),
          transaction: transaction,
        );
        if (pending != null) {
          throw MessengerDuplicateInvitationException(username: other.username);
        }

        final invitation = await ChatInvitation.db.insertRow(
          session,
          ChatInvitation(
            chatId: chat.id!,
            senderId: me.id!,
            receiverId: other.id!,
            status: ChatInvitationStatus.pending,
          ),
          transaction: transaction,
        );
        return ChatInvitationView(
          invitation: invitation,
          senderUsername: me.username,
          senderProfileImageId: (await _profiles.imageIdsByUserIds(
            session,
            [me.id!],
            transaction: transaction,
          ))[me.id!],
          receiverUsername: other.username,
          chatName: await _clientChatName(
            session,
            chat.name,
            chatId: chat.id,
          ),
          isGroup: true,
        );
      },
    );
    await _notifyInvitation(session, view);
    return view;
  }

  /// Pending invitations addressed to the current user.
  ///
  /// Uses the authenticated session's MessengerUser id. Does not accept a
  /// client-supplied receiver id.
  Future<List<ChatInvitationView>> listPendingMine(Session session) async {
    final me = await CurrentMessengerUser.require(session);
    final receiverId = me.id!;
    final invitations = await ChatInvitation.db.find(
      session,
      where: (t) =>
          t.receiverId.equals(receiverId) &
          t.status.equals(ChatInvitationStatus.pending),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
    return _viewsFor(session, invitations);
  }

  /// Accepts a pending invitation addressed to the current user.
  Future<ChatSummary> acceptInvitation(
    Session session, {
    required int invitationId,
  }) async {
    final me = await CurrentMessengerUser.require(session);
    return DatabaseUtil.runInTransactionOrSavepoint(session.db, null, (
      transaction,
    ) async {
      final invitation = await _requirePendingForReceiver(
        session,
        invitationId: invitationId,
        receiverId: me.id!,
        transaction: transaction,
      );

      if (invitation.chatId == null) {
        return _acceptDirect(
          session,
          me: me,
          invitation: invitation,
          transaction: transaction,
        );
      }
      return _acceptGroup(
        session,
        me: me,
        invitation: invitation,
        transaction: transaction,
      );
    });
  }

  /// Declines a pending invitation addressed to the current user.
  Future<ChatInvitationView> declineInvitation(
    Session session, {
    required int invitationId,
  }) async {
    final me = await CurrentMessengerUser.require(session);
    return DatabaseUtil.runInTransactionOrSavepoint(session.db, null, (
      transaction,
    ) async {
      final invitation = await _requirePendingForReceiver(
        session,
        invitationId: invitationId,
        receiverId: me.id!,
        transaction: transaction,
      );
      final declined = await ChatInvitation.db.updateRow(
        session,
        invitation.copyWith(status: ChatInvitationStatus.declined),
        transaction: transaction,
      );
      final views = await _viewsFor(session, [
        declined,
      ], transaction: transaction);
      return views.single;
    });
  }

  Future<ChatSummary> _acceptDirect(
    Session session, {
    required MessengerUser me,
    required ChatInvitation invitation,
    required Transaction transaction,
  }) async {
    var chat = await _findDirectChat(
      session,
      userIdA: invitation.senderId,
      userIdB: me.id!,
      transaction: transaction,
    );
    ChatParticipant membership;
    if (chat == null) {
      chat = await Chat.db.insertRow(
        session,
        Chat(type: ChatType.direct),
        transaction: transaction,
      );
      await ChatParticipant.db.insertRow(
        session,
        ChatParticipant(
          chatId: chat.id!,
          userId: invitation.senderId,
          role: ChatParticipantRole.member,
        ),
        transaction: transaction,
      );
      membership = await ChatParticipant.db.insertRow(
        session,
        ChatParticipant(
          chatId: chat.id!,
          userId: me.id!,
          role: ChatParticipantRole.member,
        ),
        transaction: transaction,
      );
    } else {
      membership = await _requireMembership(
        session,
        chatId: chat.id!,
        userId: me.id!,
        transaction: transaction,
      );
    }

    await ChatInvitation.db.updateRow(
      session,
      invitation.copyWith(
        status: ChatInvitationStatus.accepted,
        chatId: chat.id,
      ),
      transaction: transaction,
    );

    final sender = await MessengerUser.db.findById(
      session,
      invitation.senderId,
      transaction: transaction,
    );
    final senderImageIds = await _profiles.imageIdsByUserIds(
      session,
      [invitation.senderId],
      transaction: transaction,
    );
    return ChatSummary(
      chat: await _chatForClient(session, chat),
      membership: membership,
      otherUsernames: [sender?.username ?? 'Unknown'],
      otherAvatars: [
        UserAvatarRef(
          username: sender?.username ?? 'Unknown',
          profileImageId: senderImageIds[invitation.senderId],
        ),
      ],
      unreadCount: 0,
    );
  }

  Future<ChatSummary> _acceptGroup(
    Session session, {
    required MessengerUser me,
    required ChatInvitation invitation,
    required Transaction transaction,
  }) async {
    final chat = await Chat.db.findById(
      session,
      invitation.chatId!,
      transaction: transaction,
    );
    if (chat == null || chat.type != ChatType.group) {
      throw MessengerChatNotFoundException(chatId: invitation.chatId!);
    }

    var membership = await ChatParticipant.db.findFirstRow(
      session,
      where: (t) => t.chatId.equals(chat.id) & t.userId.equals(me.id),
      transaction: transaction,
    );
    membership ??= await ChatParticipant.db.insertRow(
      session,
      ChatParticipant(
        chatId: chat.id!,
        userId: me.id!,
        role: ChatParticipantRole.member,
      ),
      transaction: transaction,
    );

    await ChatInvitation.db.updateRow(
      session,
      invitation.copyWith(status: ChatInvitationStatus.accepted),
      transaction: transaction,
    );

    final members = await ChatParticipant.db.find(
      session,
      where: (t) => t.chatId.equals(chat.id),
      transaction: transaction,
    );
    final others = await MessengerUser.db.find(
      session,
      where: (t) => t.id.inSet(
        members
            .where((row) => row.userId != me.id)
            .map((row) => row.userId)
            .toSet(),
      ),
      transaction: transaction,
    );
    final otherIds = [for (final user in others) user.id!];
    final imageIdByUserId = await _profiles.imageIdsByUserIds(
      session,
      otherIds,
      transaction: transaction,
    );
    return ChatSummary(
      chat: await _chatForClient(session, chat),
      membership: membership,
      otherUsernames: others.map((user) => user.username).toList(),
      otherAvatars: [
        for (final user in others)
          UserAvatarRef(
            username: user.username,
            profileImageId: imageIdByUserId[user.id!],
          ),
      ],
      unreadCount: 0,
    );
  }

  Future<ChatParticipant> _updateMembership(
    Session session, {
    required int chatId,
    required ChatParticipant Function(ChatParticipant membership) update,
  }) async {
    final me = await CurrentMessengerUser.require(session);
    final membership = await _requireMembership(
      session,
      chatId: chatId,
      userId: me.id!,
    );
    return ChatParticipant.db.updateRow(session, update(membership));
  }

  Future<ChatParticipant> _requireMembership(
    Session session, {
    required int chatId,
    required int userId,
    Transaction? transaction,
  }) async {
    final chat = await Chat.db.findById(
      session,
      chatId,
      transaction: transaction,
    );
    if (chat == null) {
      throw MessengerChatNotFoundException(chatId: chatId);
    }
    final membership = await ChatParticipant.db.findFirstRow(
      session,
      where: (t) => t.chatId.equals(chatId) & t.userId.equals(userId),
      transaction: transaction,
    );
    if (membership == null) {
      throw MessengerNotChatMemberException(chatId: chatId);
    }
    return membership;
  }

  Future<Chat> _requireGroupAdmin(
    Session session, {
    required int chatId,
    required int userId,
    Transaction? transaction,
  }) async {
    final chat = await Chat.db.findById(
      session,
      chatId,
      transaction: transaction,
    );
    if (chat == null || chat.type != ChatType.group) {
      throw MessengerChatNotFoundException(chatId: chatId);
    }
    final membership = await ChatParticipant.db.findFirstRow(
      session,
      where: (t) => t.chatId.equals(chatId) & t.userId.equals(userId),
      transaction: transaction,
    );
    if (membership == null) {
      throw MessengerNotChatMemberException(chatId: chatId);
    }
    if (membership.role != ChatParticipantRole.admin) {
      throw MessengerNotChatAdminException(chatId: chatId);
    }
    return chat;
  }

  Future<ChatInvitation> _requirePendingForReceiver(
    Session session, {
    required int invitationId,
    required int receiverId,
    required Transaction transaction,
  }) async {
    final invitation = await ChatInvitation.db.findById(
      session,
      invitationId,
      transaction: transaction,
    );
    if (invitation == null || invitation.receiverId != receiverId) {
      throw MessengerInvitationNotFoundException(invitationId: invitationId);
    }
    if (invitation.status != ChatInvitationStatus.pending) {
      throw MessengerInvitationAlreadyHandledException(
        invitationId: invitationId,
      );
    }
    return invitation;
  }

  Future<MessengerUser> _requireUserByUsername(
    Session session,
    String username,
  ) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty) {
      throw MessengerInvalidChatInputException(
        field: 'username',
        message: 'Username is required.',
      );
    }
    final user = await _messengerUsers.findByUsername(
      session,
      username: trimmed,
    );
    if (user == null) {
      throw MessengerUserNotFoundException(username: trimmed);
    }
    return user;
  }

  Future<Chat?> _findDirectChat(
    Session session, {
    required int userIdA,
    required int userIdB,
    required Transaction transaction,
  }) async {
    final mine = await ChatParticipant.db.find(
      session,
      where: (t) => t.userId.equals(userIdA),
      transaction: transaction,
    );
    if (mine.isEmpty) {
      return null;
    }
    final chats = await Chat.db.find(
      session,
      where: (t) =>
          t.id.inSet(mine.map((row) => row.chatId).toSet()) &
          t.type.equals(ChatType.direct),
      transaction: transaction,
    );
    if (chats.isEmpty) {
      return null;
    }
    final other = await ChatParticipant.db.findFirstRow(
      session,
      where: (t) =>
          t.userId.equals(userIdB) &
          t.chatId.inSet(chats.map((chat) => chat.id!).toSet()),
      transaction: transaction,
    );
    if (other == null) {
      return null;
    }
    return chats.firstWhere((chat) => chat.id == other.chatId);
  }

  Future<ChatInvitation?> _findPendingDirectInvitation(
    Session session, {
    required int userIdA,
    required int userIdB,
    required Transaction transaction,
  }) {
    return ChatInvitation.db.findFirstRow(
      session,
      where: (t) =>
          t.chatId.equals(null) &
          t.status.equals(ChatInvitationStatus.pending) &
          ((t.senderId.equals(userIdA) & t.receiverId.equals(userIdB)) |
              (t.senderId.equals(userIdB) & t.receiverId.equals(userIdA))),
      transaction: transaction,
    );
  }

  Future<List<ChatInvitationView>> _viewsFor(
    Session session,
    List<ChatInvitation> invitations, {
    Transaction? transaction,
  }) async {
    if (invitations.isEmpty) {
      return [];
    }
    final userIds = {
      for (final invitation in invitations) ...[
        invitation.senderId,
        invitation.receiverId,
      ],
    };
    final users = await MessengerUser.db.find(
      session,
      where: (t) => t.id.inSet(userIds),
      transaction: transaction,
    );
    final usernameById = {
      for (final user in users) user.id!: user.username,
    };
    final imageIdByUserId = await _profiles.imageIdsByUserIds(
      session,
      invitations.map((invitation) => invitation.senderId),
      transaction: transaction,
    );
    final chatIds = invitations
        .map((invitation) => invitation.chatId)
        .whereType<int>()
        .toSet();
    final chats = chatIds.isEmpty
        ? <Chat>[]
        : await Chat.db.find(
            session,
            where: (t) => t.id.inSet(chatIds),
            transaction: transaction,
          );
    final chatById = {for (final chat in chats) chat.id!: chat};

    return [
      for (final invitation in invitations)
        ChatInvitationView(
          invitation: ChatInvitation(
            id: invitation.id,
            chatId: invitation.chatId,
            senderId: invitation.senderId,
            receiverId: invitation.receiverId,
            status: invitation.status,
            createdAt: invitation.createdAt,
          ),
          senderUsername: usernameById[invitation.senderId] ?? 'Unknown',
          senderProfileImageId: imageIdByUserId[invitation.senderId],
          receiverUsername: usernameById[invitation.receiverId] ?? 'Unknown',
          chatName: invitation.chatId == null
              ? null
              : await _clientChatName(
                  session,
                  chatById[invitation.chatId]?.name,
                  chatId: invitation.chatId,
                ),
          isGroup: invitation.chatId != null,
        ),
    ];
  }

  /// Decrypts [stored] for an API response. Direct chats keep `name` null.
  Future<Chat> _chatForClient(Session session, Chat stored) async {
    final name = stored.name;
    if (name == null) {
      return stored;
    }
    return stored.copyWith(
      name: await _clientChatName(session, name, chatId: stored.id),
    );
  }

  /// Decrypts a stored group name for the client.
  ///
  /// Direct chats store `null` and are never decrypted. An undecryptable
  /// value is omitted (`null`) so one legacy/corrupt row cannot fail the
  /// entire chat or invitation list. The stored bytes are not returned:
  /// this is not a plaintext fallback and ciphertext is not sent to Flutter.
  Future<String?> _clientChatName(
    Session session,
    String? stored, {
    int? chatId,
  }) async {
    if (stored == null) {
      return null;
    }
    try {
      return await EncryptionService.of(session).decrypt(stored);
    } on MessengerEncryptedDataException catch (error) {
      session.log(
        'Chat name decrypt failed for chatId=$chatId '
        '(${error.runtimeType})',
        level: LogLevel.warning,
      );
      return null;
    }
  }

  Future<Map<int, int>> _unreadCounts(
    Session session, {
    required int userId,
    required Set<int> chatIds,
  }) async {
    if (chatIds.isEmpty) {
      return const {};
    }

    final receipts = await MessageReceipt.db.find(
      session,
      where: (t) => t.userId.equals(userId) & t.readAt.equals(null),
      include: MessageReceipt.include(message: Message.include()),
    );

    final counts = <int, int>{};
    for (final receipt in receipts) {
      final message = receipt.message;
      if (message == null ||
          message.deletedAt != null ||
          message.senderId == userId) {
        continue;
      }
      final chatId = message.chatId;
      if (!chatIds.contains(chatId)) {
        continue;
      }
      counts[chatId] = (counts[chatId] ?? 0) + 1;
    }
    return counts;
  }

  List<String> _usernamesFor(
    List<int> userIds,
    Map<int, String> usernameById,
  ) {
    return [
      for (final userId in userIds) usernameById[userId] ?? 'Unknown',
    ];
  }

  List<UserAvatarRef> _avatarsFor(
    List<int> userIds,
    Map<int, String> usernameById,
    Map<int, int?> imageIdByUserId,
  ) {
    return [
      for (final userId in userIds)
        UserAvatarRef(
          username: usernameById[userId] ?? 'Unknown',
          profileImageId: imageIdByUserId[userId],
        ),
    ];
  }

  Future<void> _notifyInvitation(Session session, ChatInvitationView view) {
    return Messages.publishUserEvent(
      session,
      userId: view.invitation.receiverId,
      event: ChatEvent(
        kind: ChatEventKind.invitation,
        chatId: view.invitation.chatId ?? 0,
        invitation: view,
      ),
    );
  }

  int _compareChats(Chat a, Chat b) {
    final aLast = a.lastMessageAt;
    final bLast = b.lastMessageAt;
    if (aLast == null && bLast == null) {
      return b.id!.compareTo(a.id!);
    }
    if (aLast == null) {
      return 1;
    }
    if (bLast == null) {
      return -1;
    }
    final compared = bLast.compareTo(aLast);
    if (compared != 0) {
      return compared;
    }
    return b.id!.compareTo(a.id!);
  }
}
