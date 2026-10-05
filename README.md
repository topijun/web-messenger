# Web Messenger

Web Messenger is the web version of Mobile Messenger. Both use one Flutter codebase, one Serverpod backend, and one PostgreSQL database.

The client runs on Android, iOS, and Web. The web client is published at <https://topijun.github.io/web-messenger/>.

This is a student project. Encryption is application-layer encryption on the server, not end-to-end encryption.

## Features

### Authentication

- Registration with email, username, and password
- Email verification before the account is completed
- Duplicate email or username is rejected, with a message on screen
- Email/password login
- The signed-in session is kept on the device
- Password reset by email
- Password rules: at least 8 characters, with upper case, lower case, a digit, and a symbol
- Usernames: 3–30 characters, `A–Z`, `a–z`, `0–9`, `_`, `.`
- Logout signs out the current device. Another signed-in client for the same account is a separate session

### Profile

- Username
- About Me (up to 500 characters)
- Profile picture upload (JPEG or PNG, max 5 MB)
- Default avatar when no picture is set
- Any of that profile data can be edited
- Light / Dark appearance (stored on the device, not on the server)

### Contacts, invitations, and chats

- Search registered users by username or email
- Direct-chat invitations (no chat until the invitation is accepted)
- Group creation and group invitations (admin only)
- Accept or decline a pending invitation
- Pending invitations are listed, with a badge on Home
- Direct and group conversations
- Archive / unarchive and mute / unmute (per user)
- Archived chats are hidden on Home and listed under Profile → Archived
- Chat list ordered by latest message (`lastMessageAt`)
- In-app unread counts for other people’s messages, and an invitation indicator. These are not operating-system notifications

### Messaging

- Text, image, video, and audio messages
- Realtime delivery on one Serverpod channel per user
- Typing indicators
- Sent / delivered / read receipts
- Failed send shows feedback, and the message can be retried
- Edit own text messages
- Soft-delete own messages (a placeholder remains)
- Video thumbnails (first-frame JPEG posters)
- Common failures show a message and leave the conversation usable

### Message search

Search is inside one open conversation, for both direct and group chats. It is a case-insensitive match on message text.

- The server scans at most the 300 newest messages and returns at most 50 matches
- Queries longer than 200 characters are rejected
- An empty query does not search
- Deleted messages and non-text messages are skipped
- Matches are listed under the search field. Choosing a result scrolls that message into view
- On a wide layout, each open conversation has its own search

The matched words are not marked inside the message text.

### Group polls

In a group chat, a member can create a single-choice poll and mark it anonymous or public.

- The composer allows 2 to 6 options
- A direct chat cannot contain a poll
- A user can change their vote or remove it
- A public poll shows who voted for each option. An anonymous poll does not
- The question and options are encrypted on the server, like message text

### Message reactions

A message can be reacted to with a fixed set of emoji: ❤️ 👍 😂 😮 😢 😡.

- Long-press, or right-click on web, opens the choices
- Choosing an emoji adds it. Choosing it again removes it
- A different emoji is added as well; earlier reactions stay
- The count is shown when more than one person used that emoji
- Reactions work on text, image, video, audio, and poll messages
- A deleted message cannot be reacted to
- The emoji is stored as ordinary metadata. It is not encrypted

## Web-specific behavior

Mobile Messenger and Web Messenger are the same app. Layout follows the window width, not a separate web-only build.

- Width under 840: the chat list is full screen, and opening a chat replaces it. This is also how the phone layouts work
- Width of 840 or more: a 360-wide chat list stays beside the conversation
- Up to two conversations can be open at once. Each has its own composer, search, and message state
- Selecting a chat that is already open closes it
- Opening a third chat replaces the one that was selected less recently
- Shrinking the window below 840 returns to the chat list
- Web audio recording needs a secure page (`https` or `localhost`)

## Architecture

```text
Flutter client (Android / iOS / Web)
        |
        v
Serverpod API + realtime
        |
        v
PostgreSQL
```

- Flutter never talks to PostgreSQL directly
- HTTP endpoints handle auth, chats, messages, media, and profile
- Realtime events (messages, receipts, typing, edits, deletes, invitations, polls, reactions) use one channel per user
- Media bytes are stored in PostgreSQL after encryption. History and realtime carry ids, not file payloads
- In development, Redis is disabled. Realtime is in-process
- A message sent from the web client and a message sent from the mobile client are the same database rows, so both clients see them when they use the same backend

### Technologies

- Flutter, Dart 3.11.5
- Serverpod 3.4.13 (Email IDP and the Flutter client)
- PostgreSQL 16 (Docker, `pgvector/pgvector:pg16`)
- `cryptography` — AES-256-GCM on the server
- `mailer` — Gmail SMTP for verification and password-reset mail
- `image_picker`, `video_player`, `video_thumbnail`
- `record` / `audioplayers` — WAV recording and playback
- `shared_preferences` — local theme preference

### Project structure

```text
web-messenger/
├── lib/                          # Flutter application
│   ├── main.dart                 # App entry point
│   ├── app/                      # MaterialApp and theme wiring
│   ├── core/                     # API client, errors, theme, validation
│   └── features/                 # UI, controllers, and repositories
│       ├── auth/
│       ├── chats/
│       ├── messaging/
│       ├── profile/
│       ├── home/
│       ├── media/
│       └── device/
├── test/                         # Flutter tests
├── assets/                       # Client config, fonts, and images
├── web/                          # Flutter web entry and icons
├── android/                      # Android platform project
├── ios/                          # iOS platform project
├── linux/                        # Linux platform project
├── macos/                        # macOS platform project
├── windows/                      # Windows platform project
│
├── messenger_server/             # Serverpod backend
│   ├── bin/main.dart             # Server entry point
│   ├── config/                   # Serverpod configuration
│   ├── migrations/               # Database migrations
│   ├── docker-compose.yaml       # Local PostgreSQL
│   ├── lib/
│   │   ├── server.dart           # Server startup
│   │   └── src/
│   │       ├── auth/             # Endpoints, services, and .spy.yaml models
│   │       ├── chats/
│   │       ├── messages/
│   │       ├── media/
│   │       ├── profiles/
│   │       ├── users/
│   │       ├── devices/
│   │       ├── encryption/
│   │       ├── email/
│   │       └── generated/        # Generated protocol and database code
│   └── test/                     # Serverpod tests
│
├── messenger_client/             # Generated Serverpod client
│   └── lib/src/protocol/
│
└── dev-notes/                    # Design notes and review checklists
```

`lib/` is the Flutter app: screens, controllers, and the repositories that call the API. `messenger_server/` is the Serverpod backend. Its `config/` and `migrations/` are the server and database setup. Endpoint and service code sit next to the `.spy.yaml` models under `messenger_server/lib/src/`; `generated/` there is produced by Serverpod.

`messenger_client/` is generated client code, not a second application. Flutter tests are in `test/`. Serverpod tests are in `messenger_server/test/`. `web/`, `android/`, `ios/`, and the other platform folders are Flutter build support, not feature code.

## Security / encryption

The server encrypts protected values with AES-256-GCM before writing them to PostgreSQL, and decrypts them for an authorized client. The Flutter client sends and receives plaintext on the authenticated API. The server can read stored content.

Encrypted at rest:

- message text
- poll questions and option text
- profile About Me
- group chat names
- profile-picture bytes
- chat image, video, audio, and video-thumbnail bytes

Not encrypted (needed for auth, lookup, or listing):

- usernames and emails
- ids, timestamps, membership, receipts
- reaction emoji
- `Chat.lastMessageAt` (sort only; the chat list does not store a message preview)

## Testing

`dev-notes/Web Test Cases.md` is the review checklist. It does not record which checks have been run. Automated tests cover the areas below. They do not by themselves prove every checklist item, and a passing count is not recorded here.

```bash
flutter analyze
flutter test
```

Server tests (unit and Serverpod integration) live under `messenger_server/test/`:

```bash
cd messenger_server
dart analyze
dart test
```

Integration tests need the Docker test database. Running the whole server suite in parallel can collide on that database; run a single file if that happens.

| Area | Flutter tests | Server tests |
| --- | --- | --- |
| Registration, login, verification, password reset | `test/features/auth/` | `messenger_registration_test.dart`, `password_reset_test.dart`, `auth_email_delivery_test.dart` |
| Profile, avatar, theme | `test/features/profile/`, `test/core/theme/`, `test/app/` | `profile_test.dart`, `profile_image_test.dart` |
| Contacts, invitations, groups, archive, unread | `test/features/chats/` | `chat_test.dart`, `contact_search_test.dart` |
| Text, media, audio, receipts, typing, edit/delete | `test/features/messaging/conversation_screen_test.dart`, `conversation_controller_test.dart` | `message_test.dart`, `message_edit_delete_test.dart`, `chat_media_test.dart`, `message_audio_test.dart`, `typing_indicator_test.dart` |
| Message search | `test/features/messaging/conversation_search_test.dart` | `message_search_test.dart` |
| Group polls | `test/features/messaging/poll_test.dart` | `poll_test.dart` |
| Message reactions | `test/features/messaging/conversation_reaction_test.dart` | `message_reaction_test.dart` |
| Wide layout and two open conversations | `test/features/home/messenger_layout_test.dart` | — |
| Encryption | — | `encryption_service_test.dart`, `encryption_test.dart`, `chat_encryption_regression_test.dart` |

The layout tests include search, polls, and reactions staying inside the conversation where they were made.

These checklist items are not covered by an automated test in this repository:

- Opening the published GitHub Pages site
- A measured check that a text message reaches delivered status in under 2 seconds
- Logging out on one client and confirming that another client for the same account stays signed in

## Known limitations

- No operating-system push notifications. Mute is a per-chat setting; unread badges still show on muted chats
- Theme preference is per device, not per account
- Audio is WAV only, and web recording needs `https` or `localhost`
- Media is limited to the formats and sizes in the table below
- Encryption is not end-to-end; the server holds the key
- The chat list has no message or audio preview
- Search looks only at text in the current chat, only within the newest 300 messages, and does not mark the matched words in the bubble
- At most two conversations are open on a wide layout
- There is no reply-to-message action, notification sound, custom app icon, or splash screen

## Media

| Kind | Formats | Limit |
| --- | --- | --- |
| Profile picture | JPEG, PNG | 5 MB |
| Chat image | JPEG, PNG | 20 MiB |
| Chat video | MP4, QuickTime/MOV, WebM, M4V, 3GPP (magic-byte check) | 20 MiB |
| Chat audio | WAV (`audio/wav`) only | 10 MiB |
| Video poster | JPEG, first frame | 512 KiB |

Unsupported containers (for example HEIC as a chat image) are rejected. History does not include media bytes.

## Usage guide

1. Open the web app at <https://topijun.github.io/web-messenger/>, or run the client locally (see below).
2. Create an account with email, username, and password, then enter the verification code from email.
3. Log in. The profile shows the username, About Me, and a default picture until one is uploaded.
4. Search for a user by username or email and send a direct or group invitation.
5. Accept an invitation to open the chat, or decline it. Pending invitations stay listed until they are handled.
6. Send text, image, video, and audio. On your own messages, edit or delete where the action is offered.
7. In a group chat, create a poll from the composer. Votes can be changed or removed.
8. Long-press a message, or right-click it, to add or remove a reaction.
9. Use the search icon in a conversation to find text in that chat, then select a result to scroll to it.
10. On a wide window, open a second chat from the list. Select an open chat again to close that panel.
11. Archive, unarchive, or mute a chat from its details. Archived chats are under Profile → Archived.
12. Switch light and dark from Profile → Appearance.

## Test users

Shared test accounts are available so reviewers do not each need a mailbox. Because they share one database, agree which accounts each person uses.

- Alice
- Bob
- Carol
- Dave
- Frank

Email is `username@example.com`. The password for each is `Password123!`.

## Running locally

### Published web client and Android build

The web client is at <https://topijun.github.io/web-messenger/>.

An Android APK for the same project is available here:

[Download the Android APK](https://drive.google.com/file/d/1LQE4TTE8iPPWAKKWGo3RETRQMtYL-iUF/view?usp=sharing)

That APK is built to talk to the assignment backend. The device needs a network that can reach that server.

GitHub Pages serves the Flutter web client. It does not run Serverpod or PostgreSQL. The steps below are for running the backend and the client on your own machine.

### Backend

From `messenger_server/`, with Dart, Flutter, and Docker installed:

```bash
docker compose up --build --detach
dart run bin/main.dart --apply-migrations
```

- API: `http://localhost:8080/`
- The Flutter default in `assets/config.json` is that URL
- Generated Serverpod code is already in the repo. Run `serverpod generate` only after changing `.spy.yaml` files

### Flutter client

From the project root:

```bash
flutter run
```

Choose a device from the dialog. For the web client against the local API:

```bash
flutter run -d chrome
```

The client URL is `--dart-define=SERVER_URL=...`, then `assets/config.json`, then the platform localhost default.

Optional: `messenger_server` can host a built web app under `/app/` via the `flutter_build` script in `messenger_server/pubspec.yaml`.

### Local secrets

Copy `messenger_server/config/passwords.yaml.example` to gitignored `messenger_server/config/passwords.yaml`.

Required for encryption: `applicationEncryptionKey` — 32 bytes, hex (`openssl rand -hex 32`). The server will not start without a valid key. Changing the key makes existing ciphertext unreadable.

Required for registration and password-reset email: SMTP keys in the same file (or `SERVERPOD_PASSWORD_*` environment variables). `smtpPassword` is a Gmail App Password. Do not commit it. If it is missing, the server still starts, but those emails fail.

See `dev-notes/Setup.md` for the same steps.

## Email

Registration verification and password reset use Serverpod Email IDP and Gmail SMTP (`mailer`). Configuration belongs in gitignored `passwords.yaml` or environment variables, not in this file.

## Documentation

`dev-notes/` has longer notes on architecture, encryption, media, setup, and the web review checklist. This README is the project overview, setup, and usage guide.
