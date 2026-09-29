import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/app/messenger_app.dart';
import 'package:mobile_messenger/features/auth/application/auth_controller.dart';
import 'package:mobile_messenger/features/auth/domain/auth_state.dart';
import 'package:mobile_messenger/features/chats/application/chat_controller.dart';
import 'package:mobile_messenger/features/media/data/image_library_picker.dart';
import 'package:mobile_messenger/features/media/data/video_poster.dart';
import 'package:mobile_messenger/features/messaging/domain/chat_audio.dart';
import 'package:mobile_messenger/features/messaging/presentation/conversation_screen.dart';

import '../../support/auth_fakes.dart';
import '../../support/audio_fakes.dart';
import '../../support/chat_fakes.dart';
import '../../support/image_picker_fakes.dart';
import '../../support/message_fakes.dart';
import 'package:mobile_messenger/features/profile/data/profile_image_store.dart';
import 'package:mobile_messenger/features/profile/presentation/profile_scope.dart';
import 'package:mobile_messenger/features/profile/presentation/widgets/default_avatar.dart';
import 'package:mobile_messenger/features/profile/presentation/widgets/profile_avatar.dart';

import '../../support/profile_fakes.dart';
import '../../support/video_poster_fakes.dart';

void main() {
  testWidgets('conversation empty state and composer', (tester) async {
    final messages = FakeMessageRepository();
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();

    await tester.pumpWidget(
      _conversation(chatController, testDirectChat(), messages),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('conversationEmpty')), findsOneWidget);
    expect(find.byKey(const Key('messageComposer')), findsOneWidget);
    expect(find.byKey(const Key('sendMessage')), findsOneWidget);
    expect(find.byKey(const Key('directNavAvatar-1')), findsOneWidget);
    expect(find.byKey(const Key('groupNavAvatar-1')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('directNavAvatar-1')),
        matching: find.byType(DefaultAvatar),
      ),
      findsOneWidget,
    );

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('renders messages, sending, failed retry, and receipts', (
    tester,
  ) async {
    final messages = FakeMessageRepository(
      history: [
        testMessageView(
          id: 2,
          text: 'Hi Alice',
          isMine: true,
          senderUsername: 'Me',
          receipts: [
            testReceipt(
              messageId: 2,
              userId: 2,
              deliveredAt: DateTime.utc(2026, 9, 20, 12),
              readAt: DateTime.utc(2026, 9, 20, 12, 1),
            ),
          ],
        ),
        testMessageView(id: 1, text: 'Hello Bob', senderUsername: 'Alice'),
      ],
    );
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();

    await tester.pumpWidget(
      _conversation(chatController, testDirectChat(), messages),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hello Bob'), findsOneWidget);
    expect(find.text('Hi Alice'), findsOneWidget);
    expect(find.text('Read'), findsOneWidget);
    expect(find.text('Alice'), findsWidgets);

    messages.sendError = Exception('down');
    await tester.enterText(find.byKey(const Key('messageComposer')), 'Ping');
    await tester.tap(find.byKey(const Key('sendMessage')));
    await tester.pumpAndSettle();

    expect(find.text('Ping'), findsOneWidget);
    expect(find.text('Failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    messages.sendError = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Sent'), findsOneWidget);
    expect(find.text('Failed'), findsNothing);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('group conversation shows sender names', (tester) async {
    final messages = FakeMessageRepository(
      history: [
        testMessageView(
          id: 1,
          chatId: 2,
          text: 'From Bob',
          senderUsername: 'Bob',
        ),
      ],
    );
    final summary = testGroupChat();
    final chats = FakeChatRepository(chats: [summary]);
    final chatController = ChatController(repository: chats);
    await chatController.load();

    await tester.pumpWidget(_conversation(chatController, summary, messages));
    await tester.pumpAndSettle();

    expect(find.text('Weekend trip'), findsOneWidget);
    expect(find.byKey(const Key('groupNavAvatar-2')), findsOneWidget);
    expect(find.byKey(const Key('directNavAvatar-2')), findsNothing);
    expect(find.text('From Bob'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('direct conversation nav shows the other user avatar', (
    tester,
  ) async {
    final messages = FakeMessageRepository();
    final summary = testDirectChat(
      otherUsername: 'Bob',
      otherProfileImageId: 21,
    );
    final chats = FakeChatRepository(chats: [summary]);
    final chatController = ChatController(repository: chats);
    await chatController.load();

    await tester.pumpWidget(_conversation(chatController, summary, messages));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('directNavAvatar-1')), findsOneWidget);
    expect(find.byKey(const Key('groupNavAvatar-1')), findsNothing);
    expect(find.text('Bob'), findsOneWidget);
    expect(
      tester
          .widget<ProfileAvatar>(find.byKey(const Key('directNavAvatar-1')))
          .profileImageId,
      21,
    );

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('load older messages from the conversation screen', (
    tester,
  ) async {
    final messages = FakeMessageRepository(
      pageSize: 1,
      history: [
        testMessageView(
          id: 2,
          text: 'newer',
          isMine: true,
          senderUsername: 'Me',
        ),
        testMessageView(id: 1, text: 'older'),
      ],
    );
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();

    await tester.pumpWidget(
      _conversation(chatController, testDirectChat(), messages),
    );
    await tester.pumpAndSettle();

    expect(find.text('newer'), findsOneWidget);
    expect(find.text('older'), findsNothing);
    await tester.tap(find.byKey(const Key('loadOlderMessages')));
    await tester.pumpAndSettle();
    expect(find.text('older'), findsOneWidget);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('realtime event inserts a message once', (tester) async {
    final messages = FakeMessageRepository();
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();

    await tester.pumpWidget(
      MaterialApp(
        home: ConversationScreen(
          chatController: chatController,
          summary: testDirectChat(),
          messages: messages,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final view = testMessageView(id: 9, text: 'Live');
    messages.events.add(
      ChatEvent(kind: ChatEventKind.message, chatId: 1, message: view),
    );
    await tester.pumpAndSettle();
    expect(find.text('Live'), findsOneWidget);

    messages.events.add(
      ChatEvent(kind: ChatEventKind.message, chatId: 1, message: view),
    );
    await tester.pumpAndSettle();
    expect(find.text('Live'), findsOneWidget);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets(
    'MessengerApp opens a conversation from the authenticated chat list',
    (tester) async {
      final auth = AuthController(
        repository: FakeAuthRepository(currentUser: testMessengerUser()),
        session: FakeAuthSession(authenticated: true),
      );
      final chats = FakeChatRepository(chats: [testDirectChat()]);
      final messages = FakeMessageRepository(
        history: [testMessageView(text: 'Saved hello')],
      );

      await tester.pumpWidget(
        MessengerApp(auth: auth, chats: chats, messages: messages),
      );
      await tester.pumpAndSettle();

      expect(auth.state.status, AuthStatus.authenticated);
      expect(find.byKey(const Key('chatList')), findsOneWidget);

      await tester.tap(find.byKey(const Key('chatListItem-1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('conversationScreen')), findsOneWidget);
      expect(find.text('Saved hello'), findsOneWidget);
      expect(find.byKey(const Key('messageComposer')), findsOneWidget);

      messages.dispose();
    },
  );

  testWidgets('shows a single media attach action on the composer', (
    tester,
  ) async {
    final messages = FakeMessageRepository();
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();

    await tester.pumpWidget(
      _conversation(chatController, testDirectChat(), messages),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('attachMedia')), findsOneWidget);
    await tester.tap(find.byKey(const Key('attachMedia')));
    await tester.pumpAndSettle();
    expect(find.text('Photo'), findsNothing);
    expect(find.text('Video'), findsNothing);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('media attach drafts and sends a selected image', (tester) async {
    final messages = FakeMessageRepository();
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();
    final picker = FakeImageLibraryPicker(
      media: fakePickedImage(bytes: testPngBytes, name: 'roll.png'),
    );

    await tester.pumpWidget(
      _conversation(
        chatController,
        testDirectChat(),
        messages,
        imagePicker: picker,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('attachMedia')));
    await tester.pumpAndSettle();

    expect(picker.pickMediaCalls, 1);
    expect(picker.pickImageCalls, 0);
    expect(find.byKey(const Key('mediaDraftLabel')), findsOneWidget);
    expect(find.textContaining('roll.png'), findsOneWidget);

    await tester.tap(find.byKey(const Key('sendMessage')));
    await tester.pumpAndSettle();

    expect(messages.sentMedia, [testPngBytes]);
    expect(find.byKey(const Key('imageMessage-s-101')), findsOneWidget);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('media attach drafts and sends a selected video', (tester) async {
    final messages = FakeMessageRepository();
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();
    final picker = FakeImageLibraryPicker(
      media: fakePickedImage(bytes: testMp4Bytes, name: 'clip.mp4'),
    );

    await tester.pumpWidget(
      _conversation(
        chatController,
        testDirectChat(),
        messages,
        imagePicker: picker,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('attachMedia')));
    await tester.pumpAndSettle();

    expect(picker.pickMediaCalls, 1);
    expect(picker.pickImageCalls, 0);
    expect(find.byKey(const Key('mediaDraftLabel')), findsOneWidget);
    expect(find.textContaining('clip.mp4'), findsOneWidget);

    await tester.tap(find.byKey(const Key('sendMessage')));
    await tester.pump();
    await tester.pump();

    expect(messages.sentMedia, [testMp4Bytes]);
    expect(find.byKey(const Key('videoMessage-s-101')), findsOneWidget);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('unsupported media from the picker uses existing validation', (
    tester,
  ) async {
    final messages = FakeMessageRepository();
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();
    final picker = FakeImageLibraryPicker(
      media: fakePickedImage(
        bytes: Uint8List.fromList(const [0x00, 0x01]),
        name: 'notes.heic',
      ),
    );

    await tester.pumpWidget(
      _conversation(
        chatController,
        testDirectChat(),
        messages,
        imagePicker: picker,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('attachMedia')));
    await tester.pumpAndSettle();

    expect(picker.pickMediaCalls, 1);
    expect(find.byKey(const Key('mediaDraftLabel')), findsNothing);
    expect(messages.sentMedia, isEmpty);
    expect(
      find.text('Chat media must be JPEG, PNG, MP4, WebM, MOV, or 3GP.'),
      findsOneWidget,
    );

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('renders an image message', (tester) async {
    final messages = FakeMessageRepository(
      history: [
        testMessageView(
          id: 3,
          text: '',
          isMine: true,
          senderUsername: 'Me',
          type: MessageType.image,
          mediaId: 9,
        ),
      ],
    );
    messages.mediaById[9] = testChatMedia(
      mediaId: 9,
      mimeType: 'image/png',
      bytes: testPngBytes,
    );
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();

    await tester.pumpWidget(
      _conversation(chatController, testDirectChat(), messages),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('imageMessage-s-3')), findsOneWidget);
    expect(find.text('Sent'), findsOneWidget);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('video messages show posters and do not fetch full videos', (
    tester,
  ) async {
    final messages = FakeMessageRepository(
      history: [
        testMessageView(
          id: 8,
          text: '',
          type: MessageType.video,
          mediaId: 12,
          thumbnailMediaId: 21,
        ),
        testMessageView(
          id: 9,
          text: '',
          type: MessageType.video,
          mediaId: 13,
          thumbnailMediaId: 22,
        ),
      ],
    );
    messages.mediaById[21] = testChatMedia(
      mediaId: 21,
      mimeType: 'image/jpeg',
      bytes: testPngBytes,
    );
    messages.mediaById[22] = testChatMedia(
      mediaId: 22,
      mimeType: 'image/jpeg',
      bytes: testPngBytes,
    );
    messages.mediaById[12] = testChatMedia(
      mediaId: 12,
      type: MediaType.video,
      mimeType: 'video/mp4',
      bytes: testMp4Bytes,
    );
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();

    await tester.pumpWidget(
      _conversation(chatController, testDirectChat(), messages),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('videoThumb-s-8')), findsOneWidget);
    expect(find.byKey(const Key('videoThumb-s-9')), findsOneWidget);
    expect(messages.mediaRequests, unorderedEquals(<int>[21, 22]));

    await tester.tap(find.byKey(const Key('videoPlay-12')));
    await tester.pump();
    await tester.pump();
    expect(messages.mediaRequests, unorderedEquals(<int>[21, 22, 12]));

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('video play failure keeps the conversation usable', (
    tester,
  ) async {
    final messages = FakeMessageRepository(
      history: [
        testMessageView(id: 8, text: '', type: MessageType.video, mediaId: 12),
      ],
      mediaError: Exception('down'),
    );
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();

    await tester.pumpWidget(
      _conversation(chatController, testDirectChat(), messages),
    );
    await tester.pump();
    expect(find.byKey(const Key('videoMessage-s-8')), findsOneWidget);
    expect(find.byKey(const Key('mediaError-s-8')), findsNothing);

    await tester.tap(find.byKey(const Key('videoPlay-12')));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('mediaError-s-8')), findsOneWidget);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('realtime video uses a poster and does not fetch the file', (
    tester,
  ) async {
    final messages = FakeMessageRepository();
    messages.mediaById[41] = testChatMedia(
      mediaId: 41,
      mimeType: 'image/jpeg',
      bytes: testPngBytes,
    );
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();
    await tester.pumpWidget(
      _conversation(chatController, testDirectChat(), messages),
    );
    await tester.pumpAndSettle();

    messages.events.add(
      ChatEvent(
        kind: ChatEventKind.message,
        chatId: 1,
        message: testMessageView(
          id: 40,
          text: '',
          type: MessageType.video,
          mediaId: 30,
          thumbnailMediaId: 41,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('videoThumb-s-40')), findsOneWidget);
    expect(messages.mediaRequests, [41]);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('remote typing indicator appears and disappears', (tester) async {
    final messages = FakeMessageRepository();
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();

    await tester.pumpWidget(
      _conversation(chatController, testDirectChat(), messages),
    );
    await tester.pumpAndSettle();

    messages.events.add(
      ChatEvent(
        kind: ChatEventKind.typingStarted,
        chatId: 1,
        typingUserId: 2,
        typingUsername: 'Alice',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('typingIndicator')), findsOneWidget);
    expect(find.text('Alice is typing…'), findsOneWidget);

    messages.events.add(
      ChatEvent(
        kind: ChatEventKind.typingStopped,
        chatId: 1,
        typingUserId: 2,
        typingUsername: 'Alice',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('typingIndicator')), findsNothing);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('composer text emits typing without blocking send', (
    tester,
  ) async {
    final messages = FakeMessageRepository();
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();

    await tester.pumpWidget(
      _conversation(chatController, testDirectChat(), messages),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('messageComposer')), 'Hello');
    await tester.pump();
    expect(messages.typingUpdates.single.isTyping, isTrue);

    await tester.tap(find.byKey(const Key('sendMessage')));
    await tester.pumpAndSettle();
    expect(messages.typingUpdates.last.isTyping, isFalse);
    expect(find.text('Hello'), findsOneWidget);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('own text shows edit and delete; others do not', (tester) async {
    final messages = FakeMessageRepository(
      history: [
        testMessageView(
          id: 2,
          text: 'Mine',
          isMine: true,
          senderUsername: 'Me',
          senderId: 1,
        ),
        testMessageView(id: 1, text: 'Theirs', senderUsername: 'Alice'),
      ],
    );
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();
    await tester.pumpWidget(
      _conversation(chatController, testDirectChat(), messages),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(const Key('messageBubble-s-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reactionChoice-❤️')), findsOneWidget);
    expect(find.byKey(const Key('editMessageAction')), findsNothing);
    expect(find.byKey(const Key('deleteMessageAction')), findsNothing);
    Navigator.pop(tester.element(find.byKey(const Key('reactionChoice-❤️'))));
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(const Key('messageBubble-s-2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editMessageAction')), findsOneWidget);
    expect(find.byKey(const Key('deleteMessageAction')), findsOneWidget);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('own media shows delete only', (tester) async {
    final messages =
        FakeMessageRepository(
            history: [
              testMessageView(
                id: 3,
                text: '',
                isMine: true,
                senderUsername: 'Me',
                senderId: 1,
                type: MessageType.image,
                mediaId: 9,
              ),
            ],
          )
          ..mediaById[9] = testChatMedia(
            mediaId: 9,
            mimeType: 'image/png',
            bytes: testPngBytes,
          );
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();
    await tester.pumpWidget(
      _conversation(chatController, testDirectChat(), messages),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(const Key('messageBubble-s-3')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editMessageAction')), findsNothing);
    expect(find.byKey(const Key('deleteMessageAction')), findsOneWidget);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('edit mode populates composer and cancel restores it', (
    tester,
  ) async {
    final messages = FakeMessageRepository(
      history: [
        testMessageView(
          id: 4,
          text: 'Draft me',
          isMine: true,
          senderUsername: 'Me',
          senderId: 1,
        ),
      ],
    );
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();
    await tester.pumpWidget(
      _conversation(chatController, testDirectChat(), messages),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(const Key('messageBubble-s-4')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editMessageAction')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editModeBanner')), findsOneWidget);
    expect(find.text('Draft me'), findsWidgets);

    await tester.tap(find.byKey(const Key('cancelEdit')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editModeBanner')), findsNothing);
    expect(find.text('Draft me'), findsOneWidget);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('successful edit updates the bubble', (tester) async {
    final messages = FakeMessageRepository(
      history: [
        testMessageView(
          id: 5,
          text: 'Before',
          isMine: true,
          senderUsername: 'Me',
          senderId: 1,
        ),
      ],
    );
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();
    await tester.pumpWidget(
      _conversation(chatController, testDirectChat(), messages),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(const Key('messageBubble-s-5')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editMessageAction')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('messageComposer')), 'After');
    await tester.tap(find.byKey(const Key('saveEdit')));
    await tester.pumpAndSettle();

    expect(find.text('After'), findsOneWidget);
    expect(find.byKey(const Key('editedLabel-s-5')), findsOneWidget);
    expect(find.text('Before'), findsNothing);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('delete confirmation replaces content with a placeholder', (
    tester,
  ) async {
    final messages = FakeMessageRepository(
      history: [
        testMessageView(
          id: 6,
          text: 'Remove me',
          isMine: true,
          senderUsername: 'Me',
          senderId: 1,
        ),
      ],
    );
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();
    await tester.pumpWidget(
      _conversation(chatController, testDirectChat(), messages),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(const Key('messageBubble-s-6')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('deleteMessageAction')));
    await tester.pumpAndSettle();
    expect(find.text('Delete message?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirmDeleteMessage')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('deletedMessage-s-6')), findsOneWidget);
    expect(find.text('Remove me'), findsNothing);

    await tester.longPress(find.byKey(const Key('messageBubble-s-6')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editMessageAction')), findsNothing);
    expect(find.byKey(const Key('deleteMessageAction')), findsNothing);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('deleted media cannot be opened', (tester) async {
    final messages =
        FakeMessageRepository(
            history: [
              testMessageView(
                id: 8,
                text: '',
                isMine: true,
                senderUsername: 'Me',
                senderId: 1,
                type: MessageType.image,
                mediaId: 22,
                deletedAt: DateTime.utc(2026, 9, 21, 15),
              ),
            ],
          )
          ..mediaById[22] = testChatMedia(
            mediaId: 22,
            mimeType: 'image/png',
            bytes: testPngBytes,
          );
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();
    await tester.pumpWidget(
      _conversation(chatController, testDirectChat(), messages),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('deletedMessage-s-8')), findsOneWidget);
    expect(find.byKey(const Key('imageMessage-s-8')), findsNothing);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('realtime edit and delete update the existing bubble', (
    tester,
  ) async {
    final messages = FakeMessageRepository(
      history: [testMessageView(id: 9, text: 'Live', senderUsername: 'Alice')],
    );
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();
    await tester.pumpWidget(
      _conversation(chatController, testDirectChat(), messages),
    );
    await tester.pumpAndSettle();

    messages.events.add(
      ChatEvent(
        kind: ChatEventKind.messageEdited,
        chatId: 1,
        message: testMessageView(
          id: 9,
          text: 'Edited live',
          senderUsername: 'Alice',
          editedAt: DateTime.utc(2026, 9, 21, 16),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Edited live'), findsOneWidget);
    expect(find.byKey(const Key('editedLabel-s-9')), findsOneWidget);
    expect(find.text('Live'), findsNothing);

    messages.events.add(
      ChatEvent(
        kind: ChatEventKind.messageDeleted,
        chatId: 1,
        message: testMessageView(
          id: 9,
          text: '',
          senderUsername: 'Alice',
          deletedAt: DateTime.utc(2026, 9, 21, 17),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('deletedMessage-s-9')), findsOneWidget);
    expect(find.text('Edited live'), findsNothing);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('microphone action enters recording and duration updates', (
    tester,
  ) async {
    final messages = FakeMessageRepository();
    final recorder = FakeChatAudioRecorder();
    final playback = FakeChatAudioPlayback();
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();

    await tester.pumpWidget(
      _conversation(
        chatController,
        testDirectChat(),
        messages,
        recorder: recorder,
        playback: playback,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('startAudioRecording')));
    await tester.pump();
    expect(find.byKey(const Key('recordingTimer')), findsOneWidget);
    expect(recorder.started, isTrue);
    expect(find.text('Recording 0:00'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Recording 0:02'), findsOneWidget);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('stop then cancel discards the recording', (tester) async {
    final messages = FakeMessageRepository();
    final recorder = FakeChatAudioRecorder();
    final playback = FakeChatAudioPlayback();
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();

    await tester.pumpWidget(
      _conversation(
        chatController,
        testDirectChat(),
        messages,
        recorder: recorder,
        playback: playback,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('startAudioRecording')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('stopAudioRecording')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('recordingPreview')), findsOneWidget);
    expect(recorder.started, isFalse);

    await tester.tap(find.byKey(const Key('cancelAudioRecording')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('recordingPreview')), findsNothing);
    expect(find.byKey(const Key('startAudioRecording')), findsOneWidget);
    expect(messages.sentAudio, isEmpty);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('permission failure produces UI feedback', (tester) async {
    final messages = FakeMessageRepository();
    final recorder = FakeChatAudioRecorder()..permissionGranted = false;
    final playback = FakeChatAudioPlayback();
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();

    await tester.pumpWidget(
      _conversation(
        chatController,
        testDirectChat(),
        messages,
        recorder: recorder,
        playback: playback,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('startAudioRecording')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('conversationErrorBanner')), findsOneWidget);
    expect(find.textContaining('Microphone permission'), findsOneWidget);
    expect(recorder.startCount, 0);
    expect(find.byKey(const Key('recordingTimer')), findsNothing);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('recorder failure produces UI feedback', (tester) async {
    final messages = FakeMessageRepository();
    final recorder = FakeChatAudioRecorder()..startError = Exception('fail');
    final playback = FakeChatAudioPlayback();
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();

    await tester.pumpWidget(
      _conversation(
        chatController,
        testDirectChat(),
        messages,
        recorder: recorder,
        playback: playback,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('startAudioRecording')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Could not start recording'), findsOneWidget);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('dispose stops an in-progress recording', (tester) async {
    final messages = FakeMessageRepository();
    final recorder = FakeChatAudioRecorder();
    final playback = FakeChatAudioPlayback();
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();

    await tester.pumpWidget(
      _conversation(
        chatController,
        testDirectChat(),
        messages,
        recorder: recorder,
        playback: playback,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('startAudioRecording')));
    await tester.pump();
    expect(recorder.started, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(recorder.disposed, isTrue);
    expect(recorder.started, isFalse);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('recorded audio can be sent and failed send is not successful', (
    tester,
  ) async {
    final messages = FakeMessageRepository(sendError: Exception('down'));
    final recorder = FakeChatAudioRecorder();
    final playback = FakeChatAudioPlayback();
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();

    await tester.pumpWidget(
      _conversation(
        chatController,
        testDirectChat(),
        messages,
        recorder: recorder,
        playback: playback,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('startAudioRecording')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('stopAudioRecording')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sendAudioRecording')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('audioMessage-l-1')), findsOneWidget);
    expect(find.text('Failed'), findsOneWidget);
    expect(find.text('Sending'), findsNothing);
    expect(messages.sentAudio, hasLength(1));

    messages.sendError = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Sent'), findsOneWidget);
    expect(find.byKey(const Key('audioMessage-s-101')), findsOneWidget);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('text sending still works with audio recorder injected', (
    tester,
  ) async {
    final messages = FakeMessageRepository();
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();
    await tester.pumpWidget(
      _conversation(
        chatController,
        testDirectChat(),
        messages,
        recorder: FakeChatAudioRecorder(),
        playback: FakeChatAudioPlayback(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('messageComposer')), 'Hi');
    await tester.tap(find.byKey(const Key('sendMessage')));
    await tester.pumpAndSettle();
    expect(find.text('Hi'), findsOneWidget);
    expect(messages.sentTexts, ['Hi']);
    chatController.dispose();
    messages.dispose();
  });

  testWidgets('audio message play pause resume and replacement', (
    tester,
  ) async {
    final wav = testWavBytes();
    final messages =
        FakeMessageRepository(
            history: [
              testMessageView(
                id: 2,
                text: '',
                isMine: true,
                senderUsername: 'Me',
                senderId: 1,
                type: MessageType.audio,
                mediaId: 12,
              ),
              testMessageView(
                id: 1,
                text: '',
                type: MessageType.audio,
                mediaId: 11,
              ),
            ],
          )
          ..mediaById[11] = testChatMedia(
            mediaId: 11,
            type: MediaType.audio,
            mimeType: 'audio/wav',
            bytes: wav,
          )
          ..mediaById[12] = testChatMedia(
            mediaId: 12,
            type: MediaType.audio,
            mimeType: 'audio/wav',
            bytes: wav,
          );
    final playback = FakeChatAudioPlayback();
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();

    await tester.pumpWidget(
      _conversation(
        chatController,
        testDirectChat(),
        messages,
        recorder: FakeChatAudioRecorder(),
        playback: playback,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('audioMessage-s-1')), findsOneWidget);
    await tester.tap(find.byKey(const Key('audioPlay-s-1')));
    await tester.pumpAndSettle();
    expect(playback.activeKey, 's-1');
    expect(playback.stateFor('s-1'), ChatAudioPlaybackState.playing);

    await tester.tap(find.byKey(const Key('audioPause-s-1')));
    await tester.pumpAndSettle();
    expect(playback.stateFor('s-1'), ChatAudioPlaybackState.paused);

    await tester.tap(find.byKey(const Key('audioPlay-s-1')));
    await tester.pumpAndSettle();
    expect(playback.stateFor('s-1'), ChatAudioPlaybackState.playing);

    await tester.tap(find.byKey(const Key('audioPlay-s-2')));
    await tester.pumpAndSettle();
    expect(playback.activeKey, 's-2');
    expect(playback.stateFor('s-2'), ChatAudioPlaybackState.playing);
    expect(playback.stateFor('s-1'), ChatAudioPlaybackState.idle);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('playback error is displayed', (tester) async {
    final messages =
        FakeMessageRepository(
            history: [
              testMessageView(
                id: 4,
                text: '',
                type: MessageType.audio,
                mediaId: 14,
              ),
            ],
          )
          ..mediaById[14] = testChatMedia(
            mediaId: 14,
            type: MediaType.audio,
            mimeType: 'audio/wav',
            bytes: testWavBytes(),
          );
    final playback = FakeChatAudioPlayback()..playError = Exception('fail');
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();
    await tester.pumpWidget(
      _conversation(
        chatController,
        testDirectChat(),
        messages,
        recorder: FakeChatAudioRecorder(),
        playback: playback,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('audioPlay-s-4')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('audioError-s-4')), findsOneWidget);
    chatController.dispose();
    messages.dispose();
  });

  testWidgets('own audio has Delete only; others have no actions', (
    tester,
  ) async {
    final messages =
        FakeMessageRepository(
            history: [
              testMessageView(
                id: 2,
                text: '',
                isMine: true,
                senderUsername: 'Me',
                senderId: 1,
                type: MessageType.audio,
                mediaId: 22,
              ),
              testMessageView(
                id: 1,
                text: '',
                type: MessageType.audio,
                mediaId: 21,
              ),
            ],
          )
          ..mediaById[21] = testChatMedia(
            mediaId: 21,
            type: MediaType.audio,
            mimeType: 'audio/wav',
            bytes: testWavBytes(),
          )
          ..mediaById[22] = testChatMedia(
            mediaId: 22,
            type: MediaType.audio,
            mimeType: 'audio/wav',
            bytes: testWavBytes(),
          );
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();
    await tester.pumpWidget(
      _conversation(
        chatController,
        testDirectChat(),
        messages,
        recorder: FakeChatAudioRecorder(),
        playback: FakeChatAudioPlayback(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(const Key('messageBubble-s-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reactionChoice-❤️')), findsOneWidget);
    expect(find.byKey(const Key('editMessageAction')), findsNothing);
    expect(find.byKey(const Key('deleteMessageAction')), findsNothing);
    Navigator.pop(tester.element(find.byKey(const Key('reactionChoice-❤️'))));
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(const Key('messageBubble-s-2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editMessageAction')), findsNothing);
    expect(find.byKey(const Key('deleteMessageAction')), findsOneWidget);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('deleted audio shows placeholder and cannot be played', (
    tester,
  ) async {
    final messages =
        FakeMessageRepository(
            history: [
              testMessageView(
                id: 6,
                text: '',
                isMine: true,
                senderUsername: 'Me',
                senderId: 1,
                type: MessageType.audio,
                mediaId: 26,
                deletedAt: DateTime.utc(2026, 9, 22, 12),
              ),
            ],
          )
          ..mediaById[26] = testChatMedia(
            mediaId: 26,
            type: MediaType.audio,
            mimeType: 'audio/wav',
            bytes: testWavBytes(),
          );
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();
    await tester.pumpWidget(
      _conversation(
        chatController,
        testDirectChat(),
        messages,
        recorder: FakeChatAudioRecorder(),
        playback: FakeChatAudioPlayback(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('deletedMessage-s-6')), findsOneWidget);
    expect(find.byKey(const Key('audioPlay-s-6')), findsNothing);
    expect(find.byKey(const Key('audioMessage-s-6')), findsNothing);
    chatController.dispose();
    messages.dispose();
  });

  testWidgets('incoming audio realtime is inserted once', (tester) async {
    final messages = FakeMessageRepository();
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();
    await tester.pumpWidget(
      _conversation(
        chatController,
        testDirectChat(),
        messages,
        recorder: FakeChatAudioRecorder(),
        playback: FakeChatAudioPlayback(),
      ),
    );
    await tester.pumpAndSettle();

    final view = testMessageView(
      id: 30,
      text: '',
      type: MessageType.audio,
      mediaId: 40,
    );
    messages.events.add(
      ChatEvent(kind: ChatEventKind.message, chatId: 1, message: view),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('audioMessage-s-30')), findsOneWidget);

    messages.events.add(
      ChatEvent(kind: ChatEventKind.message, chatId: 1, message: view),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('audioMessage-s-30')), findsOneWidget);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('sender avatars appear and consecutive same-sender rows share one',
      (
    tester,
  ) async {
    final messages = FakeMessageRepository(
      history: [
        testMessageView(
          id: 3,
          text: 'third',
          senderUsername: 'Alice',
          senderProfileImageId: 8,
        ),
        testMessageView(
          id: 2,
          text: 'second',
          senderUsername: 'Alice',
          senderProfileImageId: 8,
        ),
      ],
    );
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();

    await tester.pumpWidget(
      _conversation(chatController, testDirectChat(), messages),
    );
    await tester.pumpAndSettle();

    expect(find.text('third'), findsOneWidget);
    expect(find.text('second'), findsOneWidget);
    expect(find.byKey(const Key('messageAvatar-s-2')), findsOneWidget);
    expect(find.byKey(const Key('messageAvatar-s-3')), findsNothing);
    expect(find.text('Alice'), findsOneWidget);

    chatController.dispose();
    messages.dispose();
  });

  testWidgets('deleted and edited rows still render with avatars', (
    tester,
  ) async {
    final messages = FakeMessageRepository(
      history: [
        testMessageView(
          id: 3,
          text: 'gone',
          deletedAt: DateTime.utc(2026, 9, 24),
          senderUsername: 'Alice',
          senderProfileImageId: 8,
        ),
        testMessageView(
          id: 2,
          text: 'edited body',
          editedAt: DateTime.utc(2026, 9, 24),
          senderUsername: 'Bob',
          senderProfileImageId: 7,
        ),
      ],
    );
    final chats = FakeChatRepository(chats: [testDirectChat()]);
    final chatController = ChatController(repository: chats);
    await chatController.load();

    await tester.pumpWidget(
      _conversation(chatController, testDirectChat(), messages),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('messageAvatar-s-2')), findsOneWidget);
    expect(find.byKey(const Key('messageAvatar-s-3')), findsOneWidget);
    expect(find.byKey(const Key('deletedMessage-s-3')), findsOneWidget);
    expect(find.byKey(const Key('editedLabel-s-2')), findsOneWidget);

    chatController.dispose();
    messages.dispose();
  });
}

Widget _conversation(
  ChatController chatController,
  ChatSummary summary,
  FakeMessageRepository messages, {
  ChatAudioRecorder? recorder,
  ChatAudioPlayback? playback,
  ImageLibraryPicker? imagePicker,
  VideoPoster? poster,
}) {
  final profiles = FakeProfileRepository();
  return ProfileScope(
    repository: profiles,
    images: ProfileImageStore(profiles),
    child: MaterialApp(
      home: ConversationScreen(
        chatController: chatController,
        summary: summary,
        messages: messages,
        recorder: recorder,
        playback: playback,
        imagePicker: imagePicker,
        poster: poster ?? FakeVideoPoster(),
      ),
    ),
  );
}
