import 'dart:typed_data';

import 'package:messenger_server/src/generated/protocol.dart';
import 'package:messenger_server/src/media/media_bytes.dart';
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
    test('when sending audio then it is rejected', () async {
      await expectLater(
        () => endpoints.message.sendAudio(
          sessionBuilder,
          chatId: 1,
          bytes: ByteData.sublistView(_wavPayload()),
        ),
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
      alice = await _createUser(session, sessionBuilder, username: 'alice_aud');
      bob = await _createUser(session, sessionBuilder, username: 'bob_aud');
      carol = await _createUser(session, sessionBuilder, username: 'carol_aud');
      chatId = await _directChat(endpoints, alice, bob);
    });

    test('when sending WAV then it is stored encrypted', () async {
      final original = _wavPayload();
      final view = await endpoints.message.sendAudio(
        alice.client,
        chatId: chatId,
        bytes: ByteData.sublistView(original),
      );

      expect(view.message.type, MessageType.audio);
      expect(view.message.mediaId, isNotNull);
      expect(view.message.encryptedText, '');
      expect(view.receipts, hasLength(1));
      expect(view.receipts.single.userId, bob.user.id);

      final storedMessage = await Message.db.findById(
        session,
        view.message.id!,
      );
      expect(storedMessage?.mediaId, view.message.mediaId);
      expect(storedMessage?.type, MessageType.audio);

      final stored = await Media.db.findById(session, view.message.mediaId!);
      expect(stored, isNotNull);
      expect(stored!.type, MediaType.audio);
      expect(stored.mimeType, 'audio/wav');
      expect(stored.size, original.length);
      expect(stored.userId, alice.user.id);
      final ciphertext = uint8ListFromByteData(stored.encryptedData);
      expect(ciphertext, isNot(equals(original)));
      expect(ciphertext.first, 0x01);

      final fetched = await endpoints.message.getChatMedia(
        bob.client,
        mediaId: view.message.mediaId!,
      );
      expect(fetched.mimeType, 'audio/wav');
      expect(fetched.type, MediaType.audio);
      expect(uint8ListFromByteData(fetched.bytes), original);

      final chat = await Chat.db.findById(session, chatId);
      expect(chat?.lastMessageAt, view.message.createdAt);
      expect(chat?.updatedAt, view.message.createdAt);
    });

    test('when encrypting twice then ciphertext differs', () async {
      final original = _wavPayload();
      final first = await endpoints.message.sendAudio(
        alice.client,
        chatId: chatId,
        bytes: ByteData.sublistView(original),
      );
      final second = await endpoints.message.sendAudio(
        alice.client,
        chatId: chatId,
        bytes: ByteData.sublistView(original),
      );
      final firstCipher = uint8ListFromByteData(
        (await Media.db.findById(
          session,
          first.message.mediaId!,
        ))!.encryptedData,
      );
      final secondCipher = uint8ListFromByteData(
        (await Media.db.findById(
          session,
          second.message.mediaId!,
        ))!.encryptedData,
      );
      expect(firstCipher, isNot(equals(secondCipher)));
    });

    test('when sending an empty payload then it is rejected', () async {
      await expectLater(
        () => endpoints.message.sendAudio(
          alice.client,
          chatId: chatId,
          bytes: ByteData.sublistView(Uint8List(0)),
        ),
        throwsA(
          isA<MessengerInvalidMediaException>().having(
            (error) => error.code,
            'code',
            'empty',
          ),
        ),
      );
      expect(await Media.db.count(session), 0);
      expect(await Message.db.count(session), 0);
    });

    test('when sending a WAV header only then it is rejected', () async {
      await expectLater(
        () => endpoints.message.sendAudio(
          alice.client,
          chatId: chatId,
          bytes: ByteData.sublistView(_wavPayload(extraBytes: 0)),
        ),
        throwsA(
          isA<MessengerInvalidMediaException>().having(
            (error) => error.code,
            'code',
            'empty',
          ),
        ),
      );
      expect(await Media.db.count(session), 0);
    });

    test('when sending JPEG as audio then it is rejected', () async {
      await expectLater(
        () => endpoints.message.sendAudio(
          alice.client,
          chatId: chatId,
          bytes: ByteData.sublistView(
            Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, ...List.filled(50, 1)]),
          ),
        ),
        throwsA(
          isA<MessengerInvalidMediaException>().having(
            (error) => error.code,
            'code',
            'unsupportedFormat',
          ),
        ),
      );
      expect(await Media.db.count(session), 0);
    });

    test('when sending WAV through sendMedia then it is rejected', () async {
      await expectLater(
        () => endpoints.message.sendMedia(
          alice.client,
          chatId: chatId,
          bytes: ByteData.sublistView(_wavPayload()),
        ),
        throwsA(
          isA<MessengerInvalidMediaException>().having(
            (error) => error.code,
            'code',
            'unsupportedFormat',
          ),
        ),
      );
    });

    test('when sending more than 10 MiB then it is rejected', () async {
      final tooLarge = _wavPayload(extraBytes: Messages.maxAudioBytes - 43);
      expect(tooLarge.length, Messages.maxAudioBytes + 1);
      await expectLater(
        () => endpoints.message.sendAudio(
          alice.client,
          chatId: chatId,
          bytes: ByteData.sublistView(tooLarge),
        ),
        throwsA(
          isA<MessengerInvalidMediaException>().having(
            (error) => error.code,
            'code',
            'tooLarge',
          ),
        ),
      );
      expect(await Media.db.count(session), 0);
    });

    test('when sending exactly 10 MiB then it is accepted', () async {
      final maxValid = _wavPayload(extraBytes: Messages.maxAudioBytes - 44);
      expect(maxValid.length, Messages.maxAudioBytes);
      final view = await endpoints.message.sendAudio(
        alice.client,
        chatId: chatId,
        bytes: ByteData.sublistView(maxValid),
      );
      expect(view.message.type, MessageType.audio);
      final stored = await Media.db.findById(session, view.message.mediaId!);
      expect(stored?.size, Messages.maxAudioBytes);
    });

    test('when a non-member uploads then no rows remain', () async {
      await expectLater(
        () => endpoints.message.sendAudio(
          carol.client,
          chatId: chatId,
          bytes: ByteData.sublistView(_wavPayload()),
        ),
        throwsA(isA<MessengerNotChatMemberException>()),
      );
      expect(await Media.db.count(session), 0);
      expect(await Message.db.count(session), 0);
    });

    test('when the chat does not exist then it is rejected', () async {
      await expectLater(
        () => endpoints.message.sendAudio(
          alice.client,
          chatId: 999999,
          bytes: ByteData.sublistView(_wavPayload()),
        ),
        throwsA(isA<MessengerChatNotFoundException>()),
      );
      expect(await Media.db.count(session), 0);
    });

    test('when a non-member retrieves audio then it is rejected', () async {
      final view = await endpoints.message.sendAudio(
        alice.client,
        chatId: chatId,
        bytes: ByteData.sublistView(_wavPayload()),
      );
      await expectLater(
        () => endpoints.message.getChatMedia(
          carol.client,
          mediaId: view.message.mediaId!,
        ),
        throwsA(isA<MessengerNotChatMemberException>()),
      );
    });

    test('when the message is deleted then getChatMedia is rejected', () async {
      final view = await endpoints.message.sendAudio(
        alice.client,
        chatId: chatId,
        bytes: ByteData.sublistView(_wavPayload()),
      );
      await endpoints.message.deleteMessage(
        alice.client,
        messageId: view.message.id!,
      );
      expect(await Media.db.count(session), 1);
      await expectLater(
        () => endpoints.message.getChatMedia(
          bob.client,
          mediaId: view.message.mediaId!,
        ),
        throwsA(isA<MessengerMediaNotFoundException>()),
      );
    });

    test('when listing history then audio bytes are not included', () async {
      final view = await endpoints.message.sendAudio(
        alice.client,
        chatId: chatId,
        bytes: ByteData.sublistView(_wavPayload()),
      );
      final page = await endpoints.message.listHistory(
        bob.client,
        chatId: chatId,
      );
      expect(page.messages, hasLength(1));
      expect(page.messages.single.message.type, MessageType.audio);
      expect(page.messages.single.message.mediaId, view.message.mediaId);
      expect(page.messages.single.message.encryptedText, '');
    });

    test(
      'when Alice sends audio then Bob receives metadata without bytes',
      () async {
        final events = <ChatEvent>[];
        final stream = session.messages.createStream<ChatEvent>(
          Messages.channelForUser(bob.user.id!),
        );
        final subscription = stream.listen(events.add);

        final view = await endpoints.message.sendAudio(
          alice.client,
          chatId: chatId,
          bytes: ByteData.sublistView(_wavPayload()),
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));
        final audioEvents = events
            .where((event) => event.kind == ChatEventKind.message)
            .map((event) => event.message)
            .whereType<MessageView>()
            .toList();
        expect(audioEvents, isNotEmpty);
        expect(audioEvents.last.message.type, MessageType.audio);
        expect(audioEvents.last.message.mediaId, view.message.mediaId);
        expect(audioEvents.last.message.id, view.message.id);
        expect(audioEvents.last.isMine, isFalse);
        await subscription.cancel();
      },
    );

    test(
      'when Carol is unrelated then she does not receive the event',
      () async {
        final events = <ChatEvent>[];
        final stream = session.messages.createStream<ChatEvent>(
          Messages.channelForUser(carol.user.id!),
        );
        final subscription = stream.listen(events.add);

        await endpoints.message.sendAudio(
          alice.client,
          chatId: chatId,
          bytes: ByteData.sublistView(_wavPayload()),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(events, isEmpty);
        await subscription.cancel();
      },
    );

    test(
      'when sendAudio fails validation then no realtime is published',
      () async {
        final events = <ChatEvent>[];
        final stream = session.messages.createStream<ChatEvent>(
          Messages.channelForUser(bob.user.id!),
        );
        final subscription = stream.listen(events.add);

        await expectLater(
          () => endpoints.message.sendAudio(
            alice.client,
            chatId: chatId,
            bytes: ByteData.sublistView(Uint8List(0)),
          ),
          throwsA(isA<MessengerInvalidMediaException>()),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(events, isEmpty);
        await subscription.cancel();
      },
    );

    test('when sending text after audio then text still works', () async {
      await endpoints.message.sendAudio(
        alice.client,
        chatId: chatId,
        bytes: ByteData.sublistView(_wavPayload()),
      );
      final text = await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'after audio',
      );
      expect(text.message.type, MessageType.text);
      expect(text.message.encryptedText, 'after audio');
    });
  });

  withServerpod('Given two chats that should not share audio', (
    sessionBuilder,
    endpoints,
  ) {
    late Session session;
    late _User alice;
    late _User bob;
    late _User carol;
    late int aliceBobChat;
    late int aliceCarolChat;

    setUp(() async {
      session = sessionBuilder.build();
      alice = await _createUser(
        session,
        sessionBuilder,
        username: 'alice_aiso',
      );
      bob = await _createUser(session, sessionBuilder, username: 'bob_aiso');
      carol = await _createUser(
        session,
        sessionBuilder,
        username: 'carol_aiso',
      );
      aliceBobChat = await _directChat(endpoints, alice, bob);
      aliceCarolChat = await _directChat(endpoints, alice, carol);
      expect(aliceCarolChat, isNot(equals(aliceBobChat)));
    });

    test(
      'when audio belongs to another chat then it cannot be retrieved',
      () async {
        final bobAudio = await endpoints.message.sendAudio(
          alice.client,
          chatId: aliceBobChat,
          bytes: ByteData.sublistView(_wavPayload()),
        );
        await expectLater(
          () => endpoints.message.getChatMedia(
            carol.client,
            mediaId: bobAudio.message.mediaId!,
          ),
          throwsA(isA<MessengerNotChatMemberException>()),
        );
      },
    );

    test(
      'when media is a profile picture then getChatMedia is rejected',
      () async {
        final profile = await endpoints.profile.uploadProfileImage(
          alice.client,
          bytes: ByteData.sublistView(
            Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3]),
          ),
        );
        await expectLater(
          () => endpoints.message.getChatMedia(
            alice.client,
            mediaId: profile.mediaId,
          ),
          throwsA(isA<MessengerMediaNotFoundException>()),
        );
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

Uint8List _wavPayload({int extraBytes = 4}) {
  final bytes = Uint8List(44 + extraBytes);
  bytes[0] = 0x52;
  bytes[1] = 0x49;
  bytes[2] = 0x46;
  bytes[3] = 0x46;
  bytes[8] = 0x57;
  bytes[9] = 0x41;
  bytes[10] = 0x56;
  bytes[11] = 0x45;
  return bytes;
}
