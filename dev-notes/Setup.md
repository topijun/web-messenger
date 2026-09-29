


## Running the serverpod server

Navigate to messenger_server folder:

```
cd messenger_server
```

Run the server:

```
dart run bin/main.dart
```

Run the server in dev-mode:

```
dart run bin/main.dart --apply-migrations --dev-mode
```

> verification and password reset codes will be printed on the console


If PostgreSQL/Docker is not running:

```
docker compose up --build --detach
```

Migrate if needed:

```
dart run bin/main.dart --apply-migrations
```

Running the flutter app using the ngrok tunnel:

```
flutter run --dart-define=SERVER_URL=https://elsa-backswept-christoper.ngrok-free.dev
```

Installing the flutter app on a physical device:

```
flutter run --profile --dart-define=SERVER_URL=https://elsa-backswept-christoper.ngrok-free.dev
```



## Application-layer encryption key

The server encrypts message text, profile About Me, group names,
profile-picture bytes, and chat image/video bytes with AES-256-GCM before
PostgreSQL writes. This is not end-to-end encryption.

1. Generate a 32-byte key:

```
openssl rand -hex 32
```

2. Put it in gitignored `config/passwords.yaml` under `shared` (or the current
   run mode) as `applicationEncryptionKey`, or set
   `SERVERPOD_PASSWORD_applicationEncryptionKey`. See
   `config/passwords.yaml.example`.

The server refuses to start if the key is missing or not exactly 32 bytes.
Keep the key stable; changing it makes existing ciphertext unreadable.
Do not generate a new key on every start.

## Gmail SMTP (registration and password-reset emails)

Email IDP sends verification codes through Gmail SMTP. Put these keys in
gitignored `config/passwords.yaml` under the current run mode (usually
`development`), or set the matching `SERVERPOD_PASSWORD_*` environment
variables. See `config/passwords.yaml.example`.

```
smtpHost: smtp.gmail.com
smtpPort: '587'
smtpUsername: tictactoe.admin@gmail.com
smtpPassword: <local Gmail App Password>
smtpFrom: tictactoe.admin@gmail.com
```

`smtpPassword` must be a Gmail App Password for that mailbox. Do not commit
it, put it in README or tests, or print it in logs.

Equivalent environment variables:

```
SERVERPOD_PASSWORD_smtpHost=smtp.gmail.com
SERVERPOD_PASSWORD_smtpPort=587
SERVERPOD_PASSWORD_smtpUsername=tictactoe.admin@gmail.com
SERVERPOD_PASSWORD_smtpPassword=<local Gmail App Password>
SERVERPOD_PASSWORD_smtpFrom=tictactoe.admin@gmail.com
```

If `smtpPassword` is missing, the server still starts. Registration and
password-reset email delivery then fail with a generic error until the
password is set.

## Phase 5/6 plaintext rows

Phase 5 stored group `Chat.name` as plaintext. Phase 6 stored message text as
plaintext in `encryptedText`. After Phase 7, new writes are ciphertext. If you
have a local database from those phases, reset it rather than leaving
plaintext behind. One leftover plaintext group name no longer hides other
chats or invitations, but that group's name will not display until the
database is recreated:

```
cd messenger_server
docker compose down -v
docker compose up --detach
dart run bin/main.dart --apply-migrations
```


