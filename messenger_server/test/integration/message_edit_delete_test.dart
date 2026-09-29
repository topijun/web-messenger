import 'dart:typed_data';

import 'package:messenger_server/src/generated/protocol.dart';
import 'package:messenger_server/src/messages/messages.dart';
import 'package:messenger_server/src/users/messenger_users.dart';
import 'package:serverpod/serverpod.dart' hide Message;
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given an unauthenticated session', (
    sessionBuilder,
    endpoints,
  ) {
    test('when editing then it is rejected', () async {
      await expectLater(
        () => endpoints.message.editText(
          sessionBuilder,
          messageId: 1,
          encryptedText: 'Nope',
        ),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });

    test('when deleting then it is rejected', () async {
      await expectLater(
        () => endpoints.message.deleteMessage(sessionBuilder, messageId: 1),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });
  });

  withServerpod('Given a direct chat between Alice and Bob', (
    sessionBuilder,
    endpoints,
  ) {
    late Session session;
    late _User alice;
    late _User bob;
    late _User carol;
    late int chatId;

    setUp(() async {
      session = sessionBuilder.build();
      alice = await _createUser(session, sessionBuilder, username: 'alice_ed');
      bob = await _createUser(session, sessionBuilder, username: 'bob_ed');
      carol = await _createUser(session, sessionBuilder, username: 'carol_ed');
      chatId = await _directChat(endpoints, alice, bob);
    });

    test(
      'when Alice edits her text then ciphertext and id stay correct',
      () async {
        final sent = await endpoints.message.sendText(
          alice.client,
          chatId: chatId,
          encryptedText: 'Hello Bob',
        );
        final beforeCipher = (await Message.db.findById(
          session,
          sent.message.id!,
        ))!.encryptedText;
        final lastMessageAt = (await Chat.db.findById(
          session,
          chatId,
        ))!.lastMessageAt;

        final edited = await endpoints.message.editText(
          alice.client,
          messageId: sent.message.id!,
          encryptedText: 'Hello Bob',
        );

        expect(edited.message.id, sent.message.id);
        expect(edited.message.encryptedText, 'Hello Bob');
        expect(edited.message.editedAt, isNotNull);
        expect(edited.message.deletedAt, isNull);
        expect(edited.receipts, hasLength(1));
        expect(edited.receipts.single.userId, bob.user.id);

        final stored = await Message.db.findById(session, sent.message.id!);
        expect(stored?.encryptedText, isNot('Hello Bob'));
        expect(stored?.encryptedText, startsWith('v1:'));
        expect(stored?.encryptedText, isNot(beforeCipher));
        expect(stored?.editedAt, isNotNull);
        expect(await Message.db.count(session), 1);

        final chat = await Chat.db.findById(session, chatId);
        expect(chat?.lastMessageAt, lastMessageAt);

        final bobPage = await endpoints.message.listHistory(
          bob.client,
          chatId: chatId,
        );
        expect(bobPage.messages.single.message.encryptedText, 'Hello Bob');
        expect(bobPage.messages.single.message.editedAt, isNotNull);
      },
    );

    test('when edited text is invalid then it is rejected', () async {
      final sent = await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'Keep me',
      );
      await expectLater(
        () => endpoints.message.editText(
          alice.client,
          messageId: sent.message.id!,
          encryptedText: '   ',
        ),
        throwsA(isA<MessengerInvalidChatInputException>()),
      );
      await expectLater(
        () => endpoints.message.editText(
          alice.client,
          messageId: sent.message.id!,
          encryptedText: 'x' * (Messages.maxTextLength + 1),
        ),
        throwsA(isA<MessengerInvalidChatInputException>()),
      );
      final stored = await Message.db.findById(session, sent.message.id!);
      expect(
        (await endpoints.message.listHistory(
          alice.client,
          chatId: chatId,
        )).messages.single.message.encryptedText,
        'Keep me',
      );
      expect(stored?.editedAt, isNull);
    });

    test('when Bob edits Alice\'s message then it is rejected', () async {
      final sent = await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'Mine',
      );
      await expectLater(
        () => endpoints.message.editText(
          bob.client,
          messageId: sent.message.id!,
          encryptedText: 'Hijack',
        ),
        throwsA(isA<MessengerNotMessageOwnerException>()),
      );
    });

    test('when a non-member edits then it is rejected', () async {
      final sent = await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'Secret',
      );
      await expectLater(
        () => endpoints.message.editText(
          carol.client,
          messageId: sent.message.id!,
          encryptedText: 'Peek',
        ),
        throwsA(isA<MessengerNotChatMemberException>()),
      );
    });

    test('when the message does not exist then edit is rejected', () async {
      await expectLater(
        () => endpoints.message.editText(
          alice.client,
          messageId: 999999,
          encryptedText: 'Ghost',
        ),
        throwsA(isA<MessengerMessageNotFoundException>()),
      );
    });

    test(
      'when Alice deletes text then content is hidden and the row remains',
      () async {
        final sent = await endpoints.message.sendText(
          alice.client,
          chatId: chatId,
          encryptedText: 'Soon gone',
        );
        await endpoints.message.markDelivered(
          bob.client,
          messageIds: [sent.message.id!],
        );
        final receiptBefore = (await MessageReceipt.db.find(session)).single;
        final lastMessageAt = (await Chat.db.findById(
          session,
          chatId,
        ))!.lastMessageAt;

        final deleted = await endpoints.message.deleteMessage(
          alice.client,
          messageId: sent.message.id!,
        );

        expect(deleted.message.id, sent.message.id);
        expect(deleted.message.deletedAt, isNotNull);
        expect(deleted.message.encryptedText, isEmpty);
        expect(await Message.db.count(session), 1);
        expect(await MessageReceipt.db.count(session), 1);
        final receiptAfter = (await MessageReceipt.db.find(session)).single;
        expect(receiptAfter.deliveredAt, receiptBefore.deliveredAt);
        expect(
          (await Chat.db.findById(session, chatId))?.lastMessageAt,
          lastMessageAt,
        );

        final page = await endpoints.message.listHistory(
          bob.client,
          chatId: chatId,
        );
        expect(page.messages.single.message.id, sent.message.id);
        expect(page.messages.single.message.deletedAt, isNotNull);
        expect(page.messages.single.message.encryptedText, isEmpty);
        expect(page.messages.single.message.encryptedText, isNot('Soon gone'));
      },
    );

    test('when a deleted message is edited then it is rejected', () async {
      final sent = await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'Bye',
      );
      await endpoints.message.deleteMessage(
        alice.client,
        messageId: sent.message.id!,
      );
      await expectLater(
        () => endpoints.message.editText(
          alice.client,
          messageId: sent.message.id!,
          encryptedText: 'Back',
        ),
        throwsA(isA<MessengerInvalidChatInputException>()),
      );
    });

    test('when already deleted then delete is rejected', () async {
      final sent = await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'Once',
      );
      await endpoints.message.deleteMessage(
        alice.client,
        messageId: sent.message.id!,
      );
      await expectLater(
        () => endpoints.message.deleteMessage(
          alice.client,
          messageId: sent.message.id!,
        ),
        throwsA(isA<MessengerInvalidChatInputException>()),
      );
    });

    test('when Bob deletes Alice\'s message then it is rejected', () async {
      final sent = await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'Stay',
      );
      await expectLater(
        () => endpoints.message.deleteMessage(
          bob.client,
          messageId: sent.message.id!,
        ),
        throwsA(isA<MessengerNotMessageOwnerException>()),
      );
    });

    test('when a non-member deletes then it is rejected', () async {
      final sent = await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'Private',
      );
      await expectLater(
        () => endpoints.message.deleteMessage(
          carol.client,
          messageId: sent.message.id!,
        ),
        throwsA(isA<MessengerNotChatMemberException>()),
      );
    });

    test('when image or video is edited then it is rejected', () async {
      final image = await endpoints.message.sendMedia(
        alice.client,
        chatId: chatId,
        bytes: ByteData.sublistView(_jpegPayload()),
      );
      final video = await endpoints.message.sendMedia(
        alice.client,
        chatId: chatId,
        bytes: ByteData.sublistView(_mp4Payload()),
      );
      await expectLater(
        () => endpoints.message.editText(
          alice.client,
          messageId: image.message.id!,
          encryptedText: 'caption',
        ),
        throwsA(isA<MessengerInvalidChatInputException>()),
      );
      await expectLater(
        () => endpoints.message.editText(
          alice.client,
          messageId: video.message.id!,
          encryptedText: 'caption',
        ),
        throwsA(isA<MessengerInvalidChatInputException>()),
      );
    });

    test(
      'when image or video is deleted then media cannot be retrieved',
      () async {
        final image = await endpoints.message.sendMedia(
          alice.client,
          chatId: chatId,
          bytes: ByteData.sublistView(_jpegPayload()),
        );
        final video = await endpoints.message.sendMedia(
          alice.client,
          chatId: chatId,
          bytes: ByteData.sublistView(_mp4Payload()),
        );
        expect(await Media.db.count(session), 2);

        await endpoints.message.deleteMessage(
          alice.client,
          messageId: image.message.id!,
        );
        await endpoints.message.deleteMessage(
          alice.client,
          messageId: video.message.id!,
        );

        expect(await Message.db.count(session), 2);
        expect(await Media.db.count(session), 2);
        await expectLater(
          () => endpoints.message.getChatMedia(
            bob.client,
            mediaId: image.message.mediaId!,
          ),
          throwsA(isA<MessengerMediaNotFoundException>()),
        );
        await expectLater(
          () => endpoints.message.getChatMedia(
            alice.client,
            mediaId: video.message.mediaId!,
          ),
          throwsA(isA<MessengerMediaNotFoundException>()),
        );
      },
    );

    test('when deleting an older message then order is preserved', () async {
      final first = await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'first',
      );
      final second = await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'second',
      );
      await endpoints.message.deleteMessage(
        alice.client,
        messageId: first.message.id!,
      );
      final page = await endpoints.message.listHistory(
        bob.client,
        chatId: chatId,
      );
      expect(
        page.messages.map((view) => view.message.id),
        [second.message.id, first.message.id],
      );
      expect(page.messages.last.message.deletedAt, isNotNull);
      expect(page.messages.first.message.encryptedText, 'second');
    });

    test(
      'when Alice edits then Bob and Alice receive the event, Carol does not',
      () async {
        final sent = await endpoints.message.sendText(
          alice.client,
          chatId: chatId,
          encryptedText: 'Live',
        );
        final aliceEvents = <ChatEvent>[];
        final bobEvents = <ChatEvent>[];
        final carolEvents = <ChatEvent>[];
        final aliceSub = session.messages
            .createStream<ChatEvent>(Messages.channelForUser(alice.user.id!))
            .listen(aliceEvents.add);
        final bobSub = session.messages
            .createStream<ChatEvent>(Messages.channelForUser(bob.user.id!))
            .listen(bobEvents.add);
        final carolSub = session.messages
            .createStream<ChatEvent>(Messages.channelForUser(carol.user.id!))
            .listen(carolEvents.add);

        await endpoints.message.editText(
          alice.client,
          messageId: sent.message.id!,
          encryptedText: 'Updated',
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(
          bobEvents.where((event) => event.kind == ChatEventKind.messageEdited),
          hasLength(1),
        );
        expect(
          aliceEvents.where(
            (event) => event.kind == ChatEventKind.messageEdited,
          ),
          hasLength(1),
        );
        expect(
          carolEvents.where(
            (event) => event.kind == ChatEventKind.messageEdited,
          ),
          isEmpty,
        );
        expect(bobEvents.last.message?.message.id, sent.message.id);
        expect(bobEvents.last.message?.message.encryptedText, 'Updated');
        expect(bobEvents.last.chatId, chatId);

        await endpoints.message.deleteMessage(
          alice.client,
          messageId: sent.message.id!,
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(
          bobEvents.where(
            (event) => event.kind == ChatEventKind.messageDeleted,
          ),
          hasLength(1),
        );
        expect(
          aliceEvents.where(
            (event) => event.kind == ChatEventKind.messageDeleted,
          ),
          hasLength(1),
        );
        expect(carolEvents, isEmpty);
        expect(bobEvents.last.message?.message.deletedAt, isNotNull);
        expect(bobEvents.last.message?.message.encryptedText, isEmpty);

        await aliceSub.cancel();
        await bobSub.cancel();
        await carolSub.cancel();
      },
    );
  });
}

class _User {
  const _User({required this.user, required this.client});

  final MessengerUser user;
  final TestSessionBuilder client;
}

Future<_User> _createUser(
  Session session,
  TestSessionBuilder sessionBuilder, {
  required String username,
}) async {
  final authUser = await const AuthUsers().create(session);
  final user = await const MessengerUsers().create(
    session,
    authUserId: authUser.id,
    username: username,
  );
  return _User(
    user: user,
    client: sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        authUser.id.toString(),
        {},
      ),
    ),
  );
}

Future<int> _directChat(
  TestEndpoints endpoints,
  _User alice,
  _User bob,
) async {
  final invitation = await endpoints.chatInvitation.inviteDirect(
    alice.client,
    username: bob.user.username,
  );
  final summary = await endpoints.chatInvitation.accept(
    bob.client,
    invitationId: invitation.invitation.id!,
  );
  return summary.chat.id as int;
}

Uint8List _jpegPayload() =>
    Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 7, 8, 9]);

Uint8List _mp4Payload() => Uint8List.fromList([
  0x00,
  0x00,
  0x00,
  0x18,
  0x66,
  0x74,
  0x79,
  0x70,
  0x69,
  0x73,
  0x6F,
  0x6D,
  0x00,
  0x00,
  0x00,
  0x00,
  0x69,
  0x73,
  0x6F,
  0x6D,
  0x6D,
  0x70,
  0x34,
  0x31,
  0x01,
  0x02,
]);
