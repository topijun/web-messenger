
[[Data Structures]]
[[Domain Model]]

---
### Technology Stack

Flutter
- single code base
Serverpod
- backend server using the [[Serverpod]] framework and written in dart
PostgreSQL

Direct + group chat: same Chat model.
Sessions: device/session-specific sessions instead of user-specific global sessions.
Realtime: Serverpod's realtime/WebSocket-type connection.
Search: primarily client-side decrypted message cache, so that encryption requirements and search do not conflict unnecessarily.
Web UI: own adaptive presentation layer, not just scaled mobile UI.


---
### Project Overview

```
                    ┌──────────────────────┐
                    │       Flutter        │
                    │                      │
                    │ Android   Web   iOS  │
                    │                      │
                    │ Shared domain logic  │
                    │ Shared state         │
                    │ Shared repositories  │
                    └──────────┬───────────┘
                               │
                         HTTPS / Realtime
                               │
                    ┌──────────▼───────────┐
                    │       Serverpod      │
                    │                      │
                    │ Auth / Sessions      │
                    │ Users / Profiles     │
                    │ Invitations          │
                    │ Chats / Groups       │
                    │ Messages             │
                    │ Media                │
                    │ Notifications        │
                    └──────────┬───────────┘
                               │
                    ┌──────────▼───────────┐
                    │      PostgreSQL      │
                    │                      │
                    │ encrypted data       │
                    │ sessions             │
                    │ chat metadata        │
                    │ message metadata     │
                    └──────────────────────┘
```


---

### Strategy regarding the next task: Web Messenger

The application uses a shared Flutter codebase and backend for both mobile and web platforms. Platform-specific presentation layers provide adaptive interfaces while the underlying domain logic, data models, repositories and real-time messaging remain shared.

```
                 Messenger Core
                       │
             ┌─────────┴─────────┐
             │                   │
       Mobile presentation   Web presentation
             │                   │
          Android               Browser
          ```

```


---


```
Flutter
   │
   ├── encrypted text ───────► PostgreSQL
   │
   ├── encrypted media ──────► media storage
   │
   └── push token ───────────► notification service
   
```

---
### File Structure

#### Flutter App
```
lib/
├── app/
│
├── core/
│   ├── encryption/
│   ├── networking/
│   ├── storage/
│   ├── errors/
│   └── platform/
│
├── features/
│   ├── auth/
│   ├── profile/
│   ├── users/
│   ├── invitations/
│   ├── chats/
│   ├── messaging/
│   ├── media/
│   ├── notifications/
│   └── polls/
│
└── shared/
```

#### Backend Server
```
messenger_server/
├── lib/
│   ├── src/
│   │   ├── auth/
│   │   ├── users/
│   │   ├── profiles/
│   │   ├── invitations/
│   │   ├── chats/
│   │   ├── messages/
│   │   ├── media/
│   │   └── notifications/
│   │
│   └── server.dart
│
├── config/
└── migrations/
```


---

### Messages structure
```
messaging/
├── data/
│   ├── message_repository.dart
│   └── message_api.dart
│
├── domain/
│   ├── message.dart
│   └── message_type.dart
│
├── application/
│   └── chat_controller.dart
│
└── presentation/
    ├── shared/
    │   ├── message_bubble.dart
    │   ├── message_status.dart
    │   └── typing_indicator.dart
    │
    ├── mobile/
    │   └── mobile_chat_screen.dart
    │
    └── web/
        └── web_chat_screen.dart        
```

### Application-layer encryption (Phase 7)

This is **not** end-to-end encryption. The server encrypts sensitive content
before PostgreSQL persistence and decrypts it before returning it to an
authenticated Flutter client.

```
Flutter client
    ↓ plaintext over authenticated Serverpod
Serverpod endpoint
    ↓
EncryptionService (AES-256-GCM, 12-byte nonce, GCM tag)
    ↓ ciphertext
PostgreSQL
```

- Algorithm: AES-256-GCM
- One server-side 32-byte key in `config/passwords.yaml` (`applicationEncryptionKey`) or `SERVERPOD_PASSWORD_applicationEncryptionKey`
- The key is never sent to Flutter and is not part of generated client code
- Encrypted fields: `Message.encryptedText`, `Profile.aboutMe`, `Chat.name` (group names), `Media.encryptedData` (profile pictures and chat image/video/audio)
- Usernames and emails stay queryable (authentication and lookup)
- Relational ids, timestamps, enums, and membership rows stay unencrypted
- `Chat.lastMessageAt` is ordering metadata; the chat list does not store a plaintext message preview
- Profile pictures are JPEG/PNG, max 5 MB. Chat images/videos are JPEG/PNG/MP4/WebM, max 20 MiB. Chat audio is WAV (`audio/wav`), max 10 MiB. All are encrypted with the same key and stored as `bytea` in PostgreSQL.
- Chat list and message history return media metadata (`mediaId`, type) only. Flutter fetches decrypted bytes with `getChatMedia` after authorization.
- Typing indicators are transient `ChatEvent`s on the existing MessageCentral stream (`typingStarted` / `typingStopped`). They are not stored in PostgreSQL, Redis, or as Messages. Events carry `chatId`, `typingUserId`, and `typingUsername` only — never draft text. Membership is checked before fan-out; the sender is excluded. Flutter emits `typingStarted` on first meaningful input, refreshes every 2s while still typing, and emits `typingStopped` after 1.5s idle or on clear/send/dispose. Clients hide a remote typist after 5s without a refresh. Stream disconnect clears in-memory typists; they are not restored from the database.
- Message edit/delete (Phase 11): only the sender may edit their own text or soft-delete their own text/image/video/audio. `Message.editedAt` / `Message.deletedAt` already exist; no migration. Edits re-encrypt with a fresh nonce and do not change receipts or `lastMessageAt`. Deletes keep the Message and Media rows; APIs never return original content; `getChatMedia` is rejected after delete. Realtime kinds `messageEdited` / `messageDeleted` reuse MessageCentral. Push notifications and email search are not implemented.
- Audio messages (Phase 12): Flutter records WAV with `record` 6.2.1 (Android/iOS/Web). `MessageEndpoint.sendAudio` validates RIFF/WAVE magic bytes and a 10 MiB limit, encrypts with `encryptBytes`, and inserts `Media` + `Message.type=audio` in one transaction. Realtime/history carry `mediaId` only. Playback fetches `getChatMedia` on play, then `audioplayers` `BytesSource`. Audio cannot be edited. Microphone permission is requested when recording starts, not at app launch. Web recording needs a secure context. No waveform, transcription, background recording, or second websocket.
- Changing the key makes existing ciphertext unreadable; do not generate a new key on every start
- Chat/invitation listing decrypts `Chat.name` per row. An undecryptable name is omitted from the API response; it does not fail the whole list and is not returned as plaintext or ciphertext. Reset a pre-Phase-7 database rather than leaving plaintext group names behind.

Flutter `lib/core/encryption/` is unused: encryption lives on the server for this assignment.

