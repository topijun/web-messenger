
A message goes through one stack. The same shape is used for chats, auth, profiles, and devices.

**UI** — `lib/features/`
- `home/presentation/home_screen.dart` — authenticated shell
- `home/presentation/messenger_layout.dart` — narrow vs wide layout
- `chats/presentation/chats_home_screen.dart` — chat list
- `messaging/presentation/conversation_screen.dart` — one conversation
- `messaging/presentation/message_scope.dart` and `chats/presentation/chat_scope.dart` — hand the repositories to the screens
- Wired in `lib/app/messenger_app.dart` from `lib/main.dart`

**Controller** — `lib/features/*/application/`
- `messaging/application/conversation_controller.dart` — history, send, search, polls, reactions, and live events for one chat
- `chats/application/chat_controller.dart` — chat list, unread, and the same live events

**Repository** — `lib/features/*/data/`
- `messaging/data/message_repository.dart` — `ServerpodMessageRepository` calls the generated client
- `chats/data/chat_repository.dart`
- `lib/core/networking/api_client.dart` — builds the client
- Generated calls live in `messenger_client/lib/src/protocol/client.dart`

**Serverpod endpoint** — `messenger_server/lib/src/`
- `messages/message_endpoint.dart` — `sendText`, `listHistory`, `react`, `watch`, and the rest
- `chats/chat_endpoint.dart` and `chats/chat_invitation_endpoint.dart`

**Service / DB** — same server folders, no separate repository
- `messages/messages.dart` — membership, encrypt, save, build `MessageView`, publish
- `chats/chats.dart`
- `encryption/encryption_service.dart` — AES-256-GCM before PostgreSQL
- Tables are the `*.spy.yaml` files in `messages/`, `chats/`, `media/`, `profiles/`, `users/`, `devices/`
- Generated row access is `messenger_server/lib/src/generated/` (`Message.db` and the other models)

**Realtime → UI**
- `messages/messages.dart` posts a `ChatEvent` with `session.messages.postMessage` on `Messages.channelForUser`
- `message_endpoint.dart` `watch()` streams that channel
- `message_repository.dart` `watch()` exposes it as one broadcast stream
- `conversation_controller.dart` and `chat_controller.dart` apply the event and call `notifyListeners()`
- `conversation_screen.dart` and `chats_home_screen.dart` rebuild