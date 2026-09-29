# Mobile Messenger

## Project Overview

A full-stack messaging application for a Mobile App Development assignment.

The client is a single Flutter codebase that runs on **Android**, **iOS**, and **Web**. The backend is **Serverpod 3.4.13** with **PostgreSQL**.

This is application-layer encryption on the server, not end-to-end encryption.

## Features

### Authentication

- Registration with email and username
- Email verification before the account is completed
- Email/password login (Serverpod Email IDP)
- Persistent signed-in session
- Password reset by email
- Password rules: at least 8 characters, with upper case, lower case, a digit, and a symbol
- Usernames: 3–30 characters, `A–Z`, `a–z`, `0–9`, `_`, `.`
- Duplicate username or email is rejected

### Profile

- Username display
- About Me (up to 500 characters)
- Profile picture upload (JPEG or PNG, max 5 MB)
- Default avatar when no picture is set
- Light / Dark appearance setting (local to the device)

### Contacts and chats

- Search registered users by username or email
- Direct-chat invitations (no chat until accept)
- Group creation and group invitations (admin only)
- Accept or decline pending incoming invitations
- Invitation badge on Home
- Direct and group conversations
- Archive / unarchive and mute / unmute (per user)
- Chat list ordered by latest message (`lastMessageAt`)
- Unread counts on the chat list (other people’s unread messages)

### Messaging

- Text, image, video, and audio messages
- Realtime delivery on the existing Serverpod user channel
- Typing indicators
- Sent / delivered / read receipts
- Failed send feedback and retry
- Edit own text messages
- Soft-delete own messages (placeholder remains)
- Video thumbnails (first-frame JPEG posters)
- In-app unread and invitation indicators (not OS push)

## Technologies

- Flutter 3.41.7 / Dart 3.11.5
- Serverpod 3.4.13 (`serverpod`, Email IDP, Flutter client)
- PostgreSQL 16 (Docker, `pgvector/pgvector:pg16`)
- `cryptography` — AES-256-GCM on the server
- `mailer` — Gmail SMTP for verification and password-reset mail
- `image_picker`, `video_player`, `video_thumbnail`
- `record` / `audioplayers` — WAV recording and playback
- `shared_preferences` — local theme preference

## Quick start

The assignment backend is already running and is reachable by the supplied APK. You do **not** need Flutter, Docker, PostgreSQL, Serverpod, or SMTP to evaluate the app.

1. Clone this repository (source is here for review).
2. Download and install the Android APK:

   [Download the Android APK](https://drive.google.com/file/d/1LQE4TTE8iPPWAKKWGo3RETRQMtYL-iUF/view?usp=sharing)

3. Open the app on an Android device or emulator.
4. Register (check email for the verification code) or log in, then use chats and messages.

The APK is built to talk to the assignment backend. Keep the device on a network that can reach that server.

## Usage guide

1. Launch the app and create an account using your email address, username, and password.
2. Verify your email and log in.
3. Complete your profile and optionally add a profile picture.
4. Search for users by username or email and send chat invitations.
5. Accept an invitation to start a direct chat, or create a group chat.
6. Send text, image, video, and audio messages. Messages can be edited or deleted where supported.
7. Use the chat controls to archive or mute conversations.
8. Switch between light and dark themes from **Profile → Appearance**.
9. The application can be used on mobile and in a web browser. The backend must be running and accessible to the client.

## Test users

There are some test users available, to help testing the different features without having to register to the app with multiple working email addresses. Since all user data is in the shared database, it might be useful to decide which test users each of the reviewers is using.

Available test users:
- Alice
- Bob
- Carol
- Dave
- Frank

The email addresses are in following format: `username@example.com`, and the password for all of the test users is `Password123!`.

# Complete setup intructions

## Running the backend locally

Only needed if you want to run Serverpod yourself. Running the server locally requires having dart, flutter and docker installed.

From `messenger_server/`:

```bash
docker compose up --build --detach
dart run bin/main.dart --apply-migrations
```

- API: `http://localhost:8080/`
- Flutter default in `assets/config.json` is that same URL
- Generated Serverpod protocol is already in the repo; run `serverpod generate` only after changing `.spy.yaml` files

Navigate to the project folder (`mobile-messenger/`) and start the flutter app:

```
flutter run
```

Then select the preferred emulator from the dialog.

- The flutter app is using the `localhost:8080` as the host address by default. 

### Local secrets

Copy `messenger_server/config/passwords.yaml.example` to gitignored `messenger_server/config/passwords.yaml`.

Required for encryption: `applicationEncryptionKey` — 32 bytes, hex (`openssl rand -hex 32`). The server will not start without a valid key. Changing the key makes existing ciphertext unreadable.

Required for registration and password-reset email: SMTP keys in the same file (or `SERVERPOD_PASSWORD_*` environment variables). `smtpPassword` is a Gmail App Password. **Do not commit it.** If it is missing, the server still starts, but those emails fail.

See `dev-notes/Setup.md` for the same steps.

## Web version

There is no permanent public web deployment.

The web UI is the same Flutter project. For local development, with the backend on port 8080:

```bash
flutter run -d chrome
```

The client URL is `--dart-define=SERVER_URL=...`, then `assets/config.json`, then the platform localhost default.

Web audio recording needs a secure context (`https` or `localhost`).

Optional: `messenger_server` can host a built web app under `/app/` via the `flutter_build` script in `messenger_server/pubspec.yaml`.

## Architecture

```text
Flutter client (Android / iOS / Web)
        |
        v
Serverpod API + realtime (MessageCentral)
        |
        v
PostgreSQL
```

- Flutter never talks to PostgreSQL directly.
- HTTP endpoints handle auth, chats, messages, media, and profile.
- Realtime events (messages, receipts, typing, edits/deletes, invitations) use one per-user Serverpod channel.
- Media bytes are stored in PostgreSQL after encryption; history and realtime carry ids, not file payloads.
- In development, Redis is disabled (`config/development.yaml`). Realtime is in-process.

## Security / encryption

The server uses **application-layer AES-256-GCM** (`cryptography`) before writing protected values to PostgreSQL.

This is application-layer encryption, not end-to-end encryption (E2EE).

The Flutter client sends and receives plaintext on the authenticated API. The server encrypts on write and decrypts when an authorized client reads. The backend can decrypt stored content.

Encrypted at rest:

- message text
- profile About Me
- group chat names
- profile-picture bytes
- chat image, video, audio, and video-thumbnail bytes

Not encrypted (needed for auth, lookup, or listing):

- usernames and emails
- ids, timestamps, membership, receipts
- `Chat.lastMessageAt` (sort only; no message preview is stored)

## Media

| Kind | Formats | Limit |
| --- | --- | --- |
| Profile picture | JPEG, PNG | 5 MB |
| Chat image | JPEG, PNG | 20 MiB |
| Chat video | MP4, QuickTime/MOV, WebM, M4V, 3GPP (magic-byte check) | 20 MiB |
| Chat audio | WAV (`audio/wav`) only | 10 MiB |
| Video poster | JPEG, first frame | 512 KiB |

Unsupported containers (for example HEIC as a chat image) are rejected. History does not include media bytes.

## Email

Registration verification and password reset use Serverpod Email IDP and Gmail SMTP (`mailer`). Configuration belongs in gitignored `passwords.yaml` or environment variables, not in this file.

## Testing

Automated tests check behaviour; they do not prove the whole product is correct.

```bash
flutter analyze
flutter test
```

Current Flutter result: **211 tests passing**.

Server tests (unit + Serverpod integration) live under `messenger_server/test/`:

```bash
cd messenger_server
dart analyze
dart test
```

Integration tests need the Docker test database. Running the whole server suite in parallel can collide on the shared Postgres instance; run a single file if that happens.

## Additional feature: Dark theme

On **Profile → Appearance**, choose **Light** or **Dark**. The change applies immediately and is stored on the device with `shared_preferences`. It is not stored on the server. There is no system/automatic theme option.

## Known limitations

- No OS push notifications (APNs / FCM) in this assignment build. Mute still exists as a per-chat setting; unread badges still show on muted chats.
- Theme preference is per device, not per account.
- Audio is WAV only; web recording needs `https` or `localhost`.
- Media has the format and size limits above.
- Encryption is not E2EE; the server holds the key.
- Chat list has no message or audio preview text.
- Archived chats remain visible in the chat list

## Future improvements

- Notification sounds for incoming messages and invitations
- Reply to messages feature
- Message reactions
- App icon
- Splash screen
- Hide archived chats + Archived chats screen for getting them back

## Project structure

```text
lib/
  app/                 MaterialApp, theme wiring
  core/                theme, API client, errors, resume
  features/
    auth/ chats/ messaging/ profile/ media/ device/ home/

messenger_server/lib/src/
  auth/ users/ chats/ messages/ media/ profiles/
  encryption/ email/ devices/

messenger_client/      generated Serverpod client
dev-notes/             design and phase notes
test/                  Flutter tests
```

## Documentation

`dev-notes/` has longer notes on architecture, encryption, media, setup, and the assignment test cases. This README has the info related to testing the project.
