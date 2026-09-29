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
    test('when sending chat media then it is rejected', () async {
      await expectLater(
        () => endpoints.message.sendMedia(
          sessionBuilder,
          chatId: 1,
          bytes: ByteData.sublistView(_jpegPayload()),
        ),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });

    test('when getting chat media then it is rejected', () async {
      await expectLater(
        () => endpoints.message.getChatMedia(sessionBuilder, mediaId: 1),
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
      alice = await _createUser(session, sessionBuilder, username: 'alice_img');
      bob = await _createUser(session, sessionBuilder, username: 'bob_img');
      carol = await _createUser(session, sessionBuilder, username: 'carol_img');
      chatId = await _directChat(endpoints, alice, bob);
    });

    test('when sending a JPEG then it is stored encrypted', () async {
      final original = _jpegPayload();
      final view = await endpoints.message.sendMedia(
        alice.client,
        chatId: chatId,
        bytes: ByteData.sublistView(original),
      );

      expect(view.message.type, MessageType.image);
      expect(view.message.mediaId, isNotNull);
      expect(view.message.encryptedText, '');
      expect(view.receipts, hasLength(1));
      expect(view.receipts.single.userId, bob.user.id);

      final storedMessage = await Message.db.findById(
        session,
        view.message.id!,
      );
      expect(storedMessage?.mediaId, view.message.mediaId);
      expect(storedMessage?.type, MessageType.image);

      final stored = await Media.db.findById(session, view.message.mediaId!);
      expect(stored, isNotNull);
      expect(stored!.type, MediaType.image);
      expect(stored.mimeType, 'image/jpeg');
      expect(stored.size, original.length);
      expect(stored.userId, alice.user.id);
      final ciphertext = uint8ListFromByteData(stored.encryptedData);
      expect(ciphertext, isNot(equals(original)));
      expect(ciphertext.first, 0x01);

      final fetched = await endpoints.message.getChatMedia(
        bob.client,
        mediaId: view.message.mediaId!,
      );
      expect(fetched.mimeType, 'image/jpeg');
      expect(uint8ListFromByteData(fetched.bytes), original);

      final chat = await Chat.db.findById(session, chatId);
      expect(chat?.lastMessageAt, view.message.createdAt);
    });

    test(
      'when sending a PNG then retrieved bytes equal the original',
      () async {
        final original = _pngPayload();
        final view = await endpoints.message.sendMedia(
          alice.client,
          chatId: chatId,
          bytes: ByteData.sublistView(original),
        );
        expect(view.message.type, MessageType.image);
        final stored = await Media.db.findById(session, view.message.mediaId!);
        expect(
          uint8ListFromByteData(stored!.encryptedData),
          isNot(equals(original)),
        );
        final fetched = await endpoints.message.getChatMedia(
          alice.client,
          mediaId: view.message.mediaId!,
        );
        expect(fetched.mimeType, 'image/png');
        expect(uint8ListFromByteData(fetched.bytes), original);
      },
    );

    test('when sending MP4 then it is stored encrypted', () async {
      final original = _mp4Payload();
      final view = await endpoints.message.sendMedia(
        alice.client,
        chatId: chatId,
        bytes: ByteData.sublistView(original),
      );
      expect(view.message.type, MessageType.video);
      final stored = await Media.db.findById(session, view.message.mediaId!);
      expect(stored!.type, MediaType.video);
      expect(stored.mimeType, 'video/mp4');
      expect(
        uint8ListFromByteData(stored.encryptedData),
        isNot(equals(original)),
      );
      final fetched = await endpoints.message.getChatMedia(
        bob.client,
        mediaId: view.message.mediaId!,
      );
      expect(uint8ListFromByteData(fetched.bytes), original);
    });

    test(
      'when sending a video with a JPEG poster then both are encrypted',
      () async {
        final original = _mp4Payload();
        final poster = _jpegPayload();
        final view = await endpoints.message.sendMedia(
          alice.client,
          chatId: chatId,
          bytes: ByteData.sublistView(original),
          thumbnailBytes: ByteData.sublistView(poster),
        );
        expect(view.message.type, MessageType.video);
        expect(view.thumbnailMediaId, isNotNull);
        final video = await Media.db.findById(session, view.message.mediaId!);
        expect(video!.thumbnailMediaId, view.thumbnailMediaId);
        expect(
          uint8ListFromByteData(video.encryptedData),
          isNot(equals(original)),
        );
        final storedThumb = await Media.db.findById(
          session,
          view.thumbnailMediaId!,
        );
        expect(storedThumb!.type, MediaType.image);
        expect(storedThumb.mimeType, 'image/jpeg');
        expect(
          uint8ListFromByteData(storedThumb.encryptedData),
          isNot(equals(poster)),
        );
        final fetched = await endpoints.message.getChatMedia(
          bob.client,
          mediaId: view.thumbnailMediaId!,
        );
        expect(fetched.mediaId, view.thumbnailMediaId);
        expect(uint8ListFromByteData(fetched.bytes), poster);
        final page = await endpoints.message.listHistory(
          bob.client,
          chatId: chatId,
        );
        expect(page.messages.single.thumbnailMediaId, view.thumbnailMediaId);
      },
    );

    test('when thumbnail is not JPEG then the video is still stored', () async {
      final view = await endpoints.message.sendMedia(
        alice.client,
        chatId: chatId,
        bytes: ByteData.sublistView(_mp4Payload()),
        thumbnailBytes: ByteData.sublistView(_gifPayload()),
      );
      expect(view.message.mediaId, isNotNull);
      expect(view.thumbnailMediaId, isNull);
    });

    test('when a non-member fetches a poster then it is rejected', () async {
      final view = await endpoints.message.sendMedia(
        alice.client,
        chatId: chatId,
        bytes: ByteData.sublistView(_mp4Payload()),
        thumbnailBytes: ByteData.sublistView(_jpegPayload()),
      );
      await expectLater(
        () => endpoints.message.getChatMedia(
          carol.client,
          mediaId: view.thumbnailMediaId!,
        ),
        throwsA(isA<MessengerNotChatMemberException>()),
      );
    });

    test('when sending MOV then it is stored as QuickTime video', () async {
      final original = _quickTimePayload();
      final view = await endpoints.message.sendMedia(
        alice.client,
        chatId: chatId,
        bytes: ByteData.sublistView(original),
      );
      expect(view.message.type, MessageType.video);
      final stored = await Media.db.findById(session, view.message.mediaId!);
      expect(stored!.type, MediaType.video);
      expect(stored.mimeType, 'video/quicktime');
      final fetched = await endpoints.message.getChatMedia(
        bob.client,
        mediaId: view.message.mediaId!,
      );
      expect(uint8ListFromByteData(fetched.bytes), original);
    });

    test('when sending WebM then retrieved bytes equal the original', () async {
      final original = _webmPayload();
      final view = await endpoints.message.sendMedia(
        alice.client,
        chatId: chatId,
        bytes: ByteData.sublistView(original),
      );
      expect(view.message.type, MessageType.video);
      final stored = await Media.db.findById(session, view.message.mediaId!);
      expect(stored!.mimeType, 'video/webm');
      expect(
        uint8ListFromByteData(stored.encryptedData),
        isNot(equals(original)),
      );
      final fetched = await endpoints.message.getChatMedia(
        bob.client,
        mediaId: view.message.mediaId!,
      );
      expect(uint8ListFromByteData(fetched.bytes), original);
    });

    test('when sending an unsupported image then it is rejected', () async {
      await expectLater(
        () => endpoints.message.sendMedia(
          alice.client,
          chatId: chatId,
          bytes: ByteData.sublistView(_gifPayload()),
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
      expect(await Message.db.count(session), 0);
    });

    test('when sending an unsupported video then it is rejected', () async {
      await expectLater(
        () => endpoints.message.sendMedia(
          alice.client,
          chatId: chatId,
          bytes: ByteData.sublistView(_matroskaPayload()),
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

    test('when sending more than 20 MiB then it is rejected', () async {
      final tooLarge = Uint8List(Messages.maxChatMediaBytes + 1);
      tooLarge[0] = 0xFF;
      tooLarge[1] = 0xD8;
      tooLarge[2] = 0xFF;
      await expectLater(
        () => endpoints.message.sendMedia(
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

    test(
      'when a non-member uploads then no Media row is left behind',
      () async {
        await expectLater(
          () => endpoints.message.sendMedia(
            carol.client,
            chatId: chatId,
            bytes: ByteData.sublistView(_jpegPayload()),
          ),
          throwsA(isA<MessengerNotChatMemberException>()),
        );
        expect(await Media.db.count(session), 0);
        expect(await Message.db.count(session), 0);
      },
    );

    test('when a non-member retrieves media then it is rejected', () async {
      final view = await endpoints.message.sendMedia(
        alice.client,
        chatId: chatId,
        bytes: ByteData.sublistView(_jpegPayload()),
      );
      await expectLater(
        () => endpoints.message.getChatMedia(
          carol.client,
          mediaId: view.message.mediaId!,
        ),
        throwsA(isA<MessengerNotChatMemberException>()),
      );
    });

    test('when listing history then media bytes are not included', () async {
      final view = await endpoints.message.sendMedia(
        alice.client,
        chatId: chatId,
        bytes: ByteData.sublistView(_jpegPayload()),
      );
      final page = await endpoints.message.listHistory(
        bob.client,
        chatId: chatId,
      );
      expect(page.messages, hasLength(1));
      expect(page.messages.single.message.type, MessageType.image);
      expect(page.messages.single.message.mediaId, view.message.mediaId);
      expect(page.messages.single.message.encryptedText, '');
    });

    test(
      'when Alice sends an image then Bob receives a realtime event without bytes',
      () async {
        final events = <ChatEvent>[];
        final stream = session.messages.createStream<ChatEvent>(
          Messages.channelForUser(bob.user.id!),
        );
        final subscription = stream.listen(events.add);

        final view = await endpoints.message.sendMedia(
          alice.client,
          chatId: chatId,
          bytes: ByteData.sublistView(_pngPayload()),
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));
        final mediaEvents = events
            .where((event) => event.kind == ChatEventKind.message)
            .map((event) => event.message)
            .whereType<MessageView>()
            .toList();
        expect(mediaEvents, isNotEmpty);
        expect(mediaEvents.last.message.type, MessageType.image);
        expect(mediaEvents.last.message.mediaId, view.message.mediaId);
        expect(mediaEvents.last.isMine, isFalse);
        await subscription.cancel();
      },
    );

    test('when sending text after media then text still works', () async {
      await endpoints.message.sendMedia(
        alice.client,
        chatId: chatId,
        bytes: ByteData.sublistView(_jpegPayload()),
      );
      final text = await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'caption adjacent',
      );
      expect(text.message.type, MessageType.text);
      expect(text.message.encryptedText, 'caption adjacent');
    });
  });

  withServerpod('Given two chats that should not share media', (
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
      alice = await _createUser(session, sessionBuilder, username: 'alice_iso');
      bob = await _createUser(session, sessionBuilder, username: 'bob_iso');
      carol = await _createUser(session, sessionBuilder, username: 'carol_iso');
      aliceBobChat = await _directChat(endpoints, alice, bob);
      aliceCarolChat = await _directChat(endpoints, alice, carol);
    });

    test(
      'when media belongs to another chat then it cannot be retrieved',
      () async {
        final bobMedia = await endpoints.message.sendMedia(
          alice.client,
          chatId: aliceBobChat,
          bytes: ByteData.sublistView(_jpegPayload()),
        );
        await expectLater(
          () => endpoints.message.getChatMedia(
            carol.client,
            mediaId: bobMedia.message.mediaId!,
          ),
          throwsA(isA<MessengerNotChatMemberException>()),
        );

        final carolMedia = await endpoints.message.sendMedia(
          alice.client,
          chatId: aliceCarolChat,
          bytes: ByteData.sublistView(_pngPayload()),
        );
        await expectLater(
          () => endpoints.message.getChatMedia(
            bob.client,
            mediaId: carolMedia.message.mediaId!,
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
          bytes: ByteData.sublistView(_jpegPayload()),
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

Uint8List _jpegPayload() =>
    Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 7, 8, 9]);

Uint8List _pngPayload() => Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  1,
  2,
  3,
]);

Uint8List _gifPayload() => Uint8List.fromList([
  0x47,
  0x49,
  0x46,
  0x38,
  0x39,
  0x61,
  0x01,
  0x00,
]);

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

Uint8List _webmPayload() => Uint8List.fromList([
  0x1A,
  0x45,
  0xDF,
  0xA3,
  0x42,
  0x82,
  0x84,
  0x77,
  0x65,
  0x62,
  0x6D,
  0x01,
  0x02,
]);

Uint8List _quickTimePayload() => Uint8List.fromList([
  0x00,
  0x00,
  0x00,
  0x14,
  0x66,
  0x74,
  0x79,
  0x70,
  0x71,
  0x74,
  0x20,
  0x20,
]);

Uint8List _matroskaPayload() => Uint8List.fromList([
  0x1A,
  0x45,
  0xDF,
  0xA3,
  0x6D,
  0x61,
  0x74,
  0x72,
  0x6F,
  0x73,
  0x6B,
  0x61,
]);
