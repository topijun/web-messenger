## Phase 12 — audio messages (implemented)

Audio reuses the Phase 8–9 `Media` table and AES-256-GCM `encryptBytes` /
`decryptBytes` APIs. There is no separate Audio table, filesystem, or S3.

### Format

- Container/codec: WAV PCM (`RIFF....WAVE`)
- MIME: `audio/wav`
- Extension: `.wav`
- Maximum original size: **10 MiB** inclusive
- Platforms: Android, iOS, Web (`record` 6.2.1 `AudioEncoder.wav`)

`record` was chosen because WAV is the encoder documented as working on
Android, iOS, and Web. `audioplayers` 6.7.1 plays the decrypted bytes with
`BytesSource`. `path_provider` holds a temporary recording file on IO
platforms.

### Pipeline

```
Flutter records WAV
    ↓
validate size ≤ 10 MiB and RIFF/WAVE magic bytes
    ↓
authenticated MessageEndpoint.sendAudio
    ↓
verify chat membership
    ↓
encryptBytes (applicationEncryptionKey, fresh nonce)
    ↓
INSERT Media + Message.type=audio (same transaction)
    ↓
receipts, Chat.lastMessageAt, realtime ChatEvent (metadata only)
    ↓
Flutter getChatMedia on play
    ↓
decryptBytes → temporary BytesSource playback
```

History and `MessageEndpoint.watch` never include audio bytes.

### Recording UI

Idle composer → microphone → recording (timer, Stop, Cancel) → preview
(Send, Cancel) → send. Permission is requested when recording starts, not
at app launch. Leaving the conversation, backgrounding, cancel, send, or
dispose stops the recorder. One audio plays at a time.

### Deletion

Audio cannot be edited. The sender can soft-delete it with the Phase 11
flow. Deleted placeholders stay in history. `getChatMedia` is rejected.
Playback stops and cached bytes are discarded.

### Permissions

- Android: `RECORD_AUDIO`
- iOS/macOS: `NSMicrophoneUsageDescription`
- macOS sandbox: `com.apple.security.device.audio-input`
- Web: `getUserMedia` requires a secure context (`https` or `localhost`)

### Known limitations

No waveform, transcription, background recording, lock-screen controls,
server-side transcoding, or chat-list audio preview.

---

## Phase 9 — chat image and video messages (implemented)

Audio messages reuse the same `Media` encryption path as of Phase 12.
This phase added JPEG/PNG/MP4/WebM chat media.

### Storage

Still PostgreSQL `bytea` via Serverpod `ByteData` on `Media.encryptedData`.
No filesystem, S3, or extra service. Ciphertext is never the original JPEG/PNG/MP4/WebM.
Soft-deleted chat messages keep their `Media` row; `getChatMedia` rejects
access when `Message.deletedAt` is set. Physical media cleanup is not in this phase.

`maxRequestSize` is 22 MiB so a 20 MiB plaintext upload plus nonce/tag and
Serverpod protocol overhead can be accepted. The application limit remains
**20 MiB of original bytes**.

### Supported formats

Detected from magic bytes, not filename or client MIME:

- Images: JPEG (`FF D8 FF`), PNG (8-byte signature)
- Videos: MP4 (ISO BMFF `ftyp` with MP4-compatible major brand), WebM (EBML + `webm` DocType)

QuickTime/MOV, Matroska, GIF, and HEIC are rejected. Flutter `video_player`
supports MP4 on Android, iOS, and Web; WebM plays on Android and Web and is
best-effort on iOS.

### Pipeline

```
Flutter selects JPEG/PNG/MP4/WebM
    ↓
authenticated MessageEndpoint.sendMedia
    ↓
validate size ≤ 20 MiB and magic bytes
    ↓
verify chat membership
    ↓
encryptBytes (applicationEncryptionKey)
    ↓
INSERT Media + Message (same transaction)
    ↓
receipts, Chat.lastMessageAt, realtime ChatEvent (metadata only)
    ↓
Flutter getChatMedia after membership check
    ↓
decryptBytes → original file
```

`getChatMedia` refuses profile-picture rows and media from chats the caller
does not belong to. History and chat list never include media blobs.

---

## Phase 8 — profile pictures (implemented)

This phase added the `Media` table and profile pictures. Chat image/video
arrived in Phase 9; audio arrived in Phase 12.

### Storage decision

Serverpod 3.4.13 maps `ByteData` to PostgreSQL `bytea`. Profile pictures are at
most 5 MB, so encrypted bytes are stored **in the database** on `Media.encryptedData`.

This is simpler than a Docker volume or object store for the school assignment
and needs no extra infrastructure. Original JPEG/PNG bytes are never stored;
only AES-256-GCM ciphertext is persisted.

Phase 12 reuses the same `Media` row for WAV audio. `storageKey` is still unused.

### Model

```
Media
├── id
├── userId          (owner; profile pictures are private to that user)
├── type            image | video | audio
├── mimeType
├── size            original plaintext size
├── encryptedData   AES-256-GCM packed bytes (not Base64)
└── createdAt
```

`Profile.profileImage` → optional `Media` (`ON DELETE SET NULL`).
`null` means Flutter shows the default avatar.

### Pipeline

```
Flutter selects JPEG/PNG
    ↓
authenticated ProfileEndpoint.uploadProfileImage
    ↓
validate size ≤ 5 MB and magic bytes (JPEG FF D8 FF / PNG signature)
    ↓
EncryptionService.encryptBytes (same applicationEncryptionKey as Phase 7)
    ↓
INSERT Media.encryptedData
    ↓
UPDATE Profile.profileImageId
    ↓
delete previous Media row
```

Retrieval: `getProfileImage` decrypts for the authenticated owner only.
Chat list APIs do not include image blobs.

### Limits

- JPEG and PNG only (detected from bytes, not filename)
- 5 MB inclusive, measured on the original upload, before encryption
- Application-layer encryption, **not** E2EE

---

## 1. Media is not a file itself


The most important principle:

Media is a meta record in the database, not an actual image, video or audio file.

That is:

```
Message
│
│ mediaId
▼
Media
│
│ storageKey
▼
File storage
│
└── actual encrypted file
```

So you don't need to cram 20 MB of videos into PostgreSQL.

---

## 2. Media model

I propose a slightly more refined model:

```
Media
├── id
├── type
├── storageKey
├── mimeType
├── size
├── encryptedSize
├── createdAt
└── deletedAt
```

`type`
```
image
video
audio
```

This tells Messenger how to handle the media.

`storageKey`

For example, conceptually:

```
media/8a72.../original
```
It is not a URL visible to the user.

It is an internal identifier of the storage system that the backend uses to find the file.

`mimeType`

For example:
```
image/jpeg
image/png
video/mp4
audio/mpeg
```
This is useful for both uploads and downloads.

---

## 3. Why both size and encryptedSize?

Here is a small but useful distinction.
```
size
```
= size of the original/compressed file before encryption.
```
encryptedSize
```
= size of the encrypted file that ends up in storage.

For example:
```
Original image
8.7 MB
↓
compression
3.2 MB
↓
encryption
3.3 MB
↓
storage
```
This allows us to enforce the 20 MB limit of the assignment sensibly.

---

## 4. Where is the 20 MB limit checked?

Not in the database.

Upload-pipeline:
```
User selects file
↓
Determine media type
↓
Compress if applicable
↓
Check size <= 20 MB
↓
Encrypt
↓
Upload encrypted file
↓
Create Media record
↓
Create Message
```
That is:

> 20 MB is checked before uploading.

This is important because we don't want to send, for example, a 150 MB video to the server only to find that it is too large.

---

## 5. Image and video compression

The assignment says:

> Image/video max 20 MB after compression.

Therefore, the client must compress before encryption and upload.

For example:
```
10 MB image
↓
compression
4 MB
↓
encryption
≈4 MB
↓
upload
```
Video:
```
80 MB video
↓
compression
17 MB
↓
encryption
≈17 MB
↓
upload
```
If the result is still:
```
> 20 MB
```
→ error message to the user and no upload is done.

Audio is limited to **10 MiB** of original WAV bytes (Phase 12). The assignment's 20 MB requirement applies to image/video media.

---

## 6. Where is the actual file located?

Here I suggest that PostgreSQL is not a media storage.

Architecture:
```
Flutter
│
│ encrypted file
▼
File Storage
│
└── encrypted media blob

PostgreSQL
│
└── Media
├── id
├── type
├── storageKey
├── mimeType
└── size
```
In a school project, we can initially use file storage stored on a Docker volume in the backend, for example.

Later, it can be changed to object storage without the Message domain needing to change.

---

## 7. storageKey vs URL

I would not store the downloadUrl field in Media.

Better:
```
storageKey
```
Backend creates secure access to the file when needed.

For example:
```
Flutter
↓
"Give me media 123"
↓
Serverpod
↓
checks access
↓
returns/downloads encrypted media
```
This is especially important in Messenger:

**Alice should not be able to change the URL and download Bob's private file.**

Access to the media should be checked through ChatParticipant membership.

---

## 8. Media and permissions

Media does not need its own userId or chatId field just for permissions.

The relationship can be inferred:
```
Message
↓
Chat
↓
ChatParticipant
↓
User
```
When Alice requests Media #123:
```
Media #123
↑
Message #456
↑
Chat #10
↑
Is Alice a participant?
```
If not:
```
403 Forbidden
```
This keeps the authorization logic centralized.

---

## 9. Why deletedAt in Media?

I originally suggested it, and I would still keep it.
```
Media
├── ...
└── deletedAt
```
But an important difference:

**Message deletion does not necessarily mean that the file is immediately deleted from storage.**

For example:
```
Message
deletedAt = 22:00
```
The media may still be in storage for a while.

Later we can do a cleanup:
```
deleted media
↓
cleanup job
↓
remove physical file
```
This is safer than trying to delete the file immediately with every Message-delete.

---

## 10. Encryption

Here it is worth distinguishing two things.

### File transfer
```
Flutter
↓
HTTPS
↓
Serverpod
```
HTTPS secures data transfer.

### File storage

Assignment also requires that the media is encrypted before being stored in the database.

So our pipeline is:
```
Original file
↓
Compression
↓
Encryption
↓
Encrypted blob
↓
Storage
```
Storage does not end up with:
```
photo.jpg
video.mp4
voice-message.m4a
```
but encrypted data.

The exact encryption strategy — algorithm, key management and who can decrypt the data — should still be treated as a separate Encryption entity. I would not lock it into the Media model.

Phase 8 implements server-side AES-256-GCM for profile-picture bytes (`EncryptionService.encryptBytes`) using the existing `applicationEncryptionKey`. PostgreSQL stores ciphertext in `Media.encryptedData`. Flutter still sends and receives original JPEG/PNG through the authenticated API. Phase 9 added chat images/videos; Phase 12 added WAV audio.


---

## 11. Media is related to Message 0..1

This is an important relational decision.

A single Message can contain:
```
0 or 1 Media
```
For example:
```
Text message
mediaId = null
```
but:
```
Image message
mediaId = 123
```
Same:
```
Video message
mediaId = 124
```
and:
```
Audio message
mediaId = 125
```
Poll uses `pollId`.

This way our Message structure remains consistent.

---

## 12. Upload should be thought of in two stages

This is one thing I would like to keep in mind for implementation.

Don't think:
```
create Message
↓
upload file
```
but:
```
1. Prepare media
↓
2. Upload encrypted media
↓
3. Create Message referencing Media
```
This way, the server doesn't easily get a message that refers to a non-existent file.

Even better would be to use the state:
```
Media
status =
	uploading
	ready
	failed
	deleted
```
**But**: I wouldn't add this field to the domain model yet unless the implementation proves it's necessary. Upload state can initially be a transient state of the client.

Let's keep persistent Media as simple as possible.

---

## 🔒 Lock Media

I suggest that the final model at this point is:
```
Media
├── id
├── type
├── storageKey
├── mimeType
├── size
├── encryptedSize
├── createdAt
└── deletedAt
```
Relation:
```
Message 0..1 ───── 1 Media
```
### Responsibilities

#### Flutter/client
- file selection
- image/video compression
- 20 MB check
- encryption
- upload UI/progress
- failed upload / retry

##### Serverpod
- authentication
- authorization
- media metadata validation
- storage writing
- access checking
- media row management

#### PostgreSQL
- media metadata

#### File storage
- actual encrypted media

---

The domain now looks like this

```
User
├── Profile
├── Device
├── ChatParticipant
└── ChatInvitation

Chat
├── ChatParticipant
├── ChatInvitation
└── Message
├── MessageReceipt
└── Media
```
And the Message types:
```
text → encryptedContent
image → Media
video → Media
audio → Media
poll → Poll
```
I think this is a very neat and consistent structure now.

