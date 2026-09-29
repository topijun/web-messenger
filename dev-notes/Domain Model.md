
[[Data Structures]] has more detailed, locked-in models.

The goal is to make a **domain model that can handle the entire Mobile + Web Messenger** without having to change the basic structure later.

Starting point is that the domain has about **10 core entities** and a few enum/state types.

---

[[Serverpod]] will take care of the authentication: register, login, sessions.

---
## Final Domain Model

```
USER
│
├── User
│   ├── Profile
│   ├── Device
│   ├── ChatParticipant
│   ├── ChatInvitation
│   ├── Message
│   └── PollVote
│
CHAT
│
├── Chat
│   ├── ChatParticipant
│   ├── ChatInvitation
│   └── Message
│
MESSAGING
│
└── Message
    ├── MessageReceipt
    ├── Media
    └── Poll
          ├── PollOption
          └── PollVote
```

### Serverpod / External:

```
Serverpod Authentication
        │
        ├── authentication
        ├── tokens
        ├── persistent login
        ├── session expiry
        └── logout/revocation
```

### Responsibilities of Our Backdend/Serverpod


```
Serverpod Auth
└── AuthUser
       │
       │ 1 ─ 1
       ▼
MessengerUser
       │
       ├── 1 ─ 1 ── Profile
       │
       ├── 1 ─ N ── Device
       │
       ├── 1 ─ N ── ChatParticipant
       │
       ├── 1 ─ N ── ChatInvitation
       │
       ├── 1 ─ N ── Message
       │
       └── 1 ─ N ── PollVote

Chat
├── ChatParticipant
├── ChatInvitation
└── Message
       ├── MessageReceipt
       ├── Media
       └── Poll
              ├── PollOption
              └── PollVote
```

---

```
                         ┌─────────────┐
                         │    User     │
                         ├─────────────┤
                         │ id          │
                         │ email       │
                         │ username    │
                         │ passwordHash│
                         │ verifiedAt  │
                         └──────┬──────┘
                                │
              ┌─────────────────┼─────────────────┐
              │ 1:1             │ 1:N             │ 1:N
              ▼                 ▼                 ▼
       ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
       │   Profile   │   │   Session   │   │   Device    │
       ├─────────────┤   ├─────────────┤   ├─────────────┤
       │ userId      │   │ id          │   │ id          │
       │ aboutMe     │   │ userId      │   │ userId      │
       │ imageId     │   │ deviceId    │   │ platform    │
       │ createdAt   │   │ platform    │   │ pushToken   │
       │ updatedAt   │   │ expiresAt   │   │ createdAt   │
       └─────────────┘   │ lastActive  │   │ lastSeenAt  │
                         │ revokedAt   │   └─────────────┘
                         └──────┬──────┘
                                │
                                │ N:1
                                ▼
                           ┌─────────┐
                           │ Device  │
                           └─────────┘
```

---

## Database indexes

At least these are locked:

| Table           | Constraint / index                |
| --------------- | --------------------------------- |
| AuthUser        | Serverpod Auth takes care of this |
| Profile         | `authUserId UNIQUE`               |
| ChatParticipant | `(chatId, userId) UNIQUE`         |
| MessageReceipt  | `(messageId, userId) UNIQUE`      |
| PollVote        | `(pollId, userId) UNIQUE`         |
| Message         | `chatId + createdAt`              |
| Chat            | `lastMessageAt` tarvittaessa      |
| ChatInvitation  | receiver/status -search           |
| Device          | userId                            |

The latter are not domain constraints but performance indexes.

Serverpod's model system generates database migrations from these.

---
## Serverpod Integration

At this point I suggest that we lock the model like this
```
AUTH
└── Serverpod AuthUser

DOMAIN
├── Profile
├── Device
├── Chat
├── ChatParticipant
├── ChatInvitation
├── Message
├── MessageReceipt
├── Media
├── Poll
├── PollOption
└── PollVote
```
12 custom persistence models + Serverpod Auth.

No:

- Session
- DirectChat
- GroupChat
- GroupInvitation
- TypingIndicator
- OnlineStatus
- MessageStatus
- VoteHistory
- SearchIndex

Because these either belong to Serverpod's auth, are transient realtime data, or are unnecessary modeling at this point.

Serverpod's current documentation supports this structure well: custom domain tables can be connected to AuthUser, relations and composite unique indexes can be defined in .spy.yaml templates, and serverpod generate will produce a Dart and database layer from them.

---
## Note

Remember this:
```
Message.encryptedContent
        ↓
Message.encryptedText
```

Phase 7 stores AES-256-GCM ciphertext in `Message.encryptedText`, `Profile.aboutMe`, and `Chat.name`. Phase 8–9 store ciphertext in `Media.encryptedData` (`bytea`) for profile pictures and chat image/video. Phase 12 stores WAV audio the same way (max 10 MiB). This is application-layer encryption on the server, not E2EE. Usernames/emails stay queryable.


And this: 
```
User.email                 UNIQUE
User.username              UNIQUE
ChatParticipant(chatId,userId) UNIQUE
MessageReceipt(messageId,userId) UNIQUE
PollVote(pollId,userId)    UNIQUE
```

---





---

The following is a general overlook at the domain model. The detailed and finalized models are located in the files linked on the Data Structures page (User.md, Message.md etc.). 
## 1. Overall Picture

I see the model like this:

```text
                         ┌──────────────┐
                         │     User     │
                         └──────┬───────┘
                                │
             ┌──────────────────┼──────────────────┐
             │                  │                  │
             ▼                  ▼                  ▼
         Profile             Session           Device
                               
             │
             │
             ▼
        ChatParticipant
             │
             ▼
            Chat
          /       \
         /         \
   Invitation     Message
                    │
              ┌─────┼─────┐
              ▼     ▼     ▼
            Media  Poll  Receipt
```

In addition:

```text
User ──────────────── ChatParticipant ─────────────── Chat
  │                                                    │
  └──────────── Invitation ────────────────────────────┘
```

---
## 2. User

```text
User
├── id
├── email
├── username
├── passwordHash
├── emailVerified
├── createdAt
└── updatedAt
```

Here it is worth distinguishing **authentication-data** and profile data.

For example:

```text
User
email
passwordHash
username
emailVerified
```

vs.

```text
Profile
profilePicture
aboutMe
```

Why?

Because the user profile can change often, but authentication is a different area of ​​responsibility.

### Unique constraints

As well as:

```text
email UNIQUE
username UNIQUE
```

are mandatory at the database level.

The backend checks them before creation, but the database is the final safety net.

---

# 3. Profile

```text
Profile
├── userId
├── aboutMe
├── profileImageId
├── createdAt
└── updatedAt
```

`username` is kept in `User` at this point, as it is also used as part of the user's identity/search.

On first login:

```text
profileImageId → default profile image
aboutMe → ""
```

---

# 4. Session

This is important for the Web + Mobile version.

```text
Session
├── id
├── userId
├── platform
├── createdAt
├── expiresAt
└── revokedAt
```

For example:

```text
User
│
├── Session A → Android
│
├── Session B → Web
│
└── Session C → iOS
```

Logout means:

```text
Session A.revokedAt = now
```

not:

```text
User.loggedIn = false
```

This is how requirements 35–36 are naturally fulfilled.

---

# 5. Device

I separate `Session` and `Device`.

It may seem unnecessary at first, but push notifications make the separation useful.

```text
Device
├── id
├── userId
├── platform
├── pushToken
├── createdAt
└── lastSeenAt
```

For example, the same user:

```text
User
│
├── Device A
│ └── Android
│
└── Device B
└── Web
```

Session tells **about login**, Device tells **which device/platform notifications can be delivered to**.

---

# 6. Chat

This is the most important decision of the entire model.

```text
Chat
├── id
├── type
├── name
├── createdAt
├── updatedAt
└── lastMessageAt
```

`type`:

```text
direct
group
```

---

## Direct chat

```text
Chat #1
type = direct

Participants:
├── Alice
└── Bob
```

## Group chat

```text
Chat #2
type = group

Participants:
├── Alice
├── Bob
├── Charlie
└── David
```

This way we never have to build two different message systems.

---

# 7. ChatParticipant

This is a very important table.

```text
ChatParticipant
├── chatId
├── userId
├── role
├── joinedAt
├── archived
└── notificationsMuted
```

`role` could be:

```text
member
admin
```

Possibly later:

```text
owner
admin
member
```

But **I wouldn't add the owner/admin system yet** unless it's needed.

### Why is archive included here?

Because archive is per-user.

Alice can do:

```text
Chat #1 → archived = true
```

but Bob can do:

```text
Chat #1 → archived = false
```

Exactly what we want.

The same goes for:

```text
notificationsMuted
```

Alice can mute the chat without muting Bob's notifications.

---

# 8. Invitation

I would make one general invitation template.

```text
ChatInvitation
├── id
├── chatId
├── senderId
├── receiverId
├── status
└── createdAt
```

Status:

```text
pending
accepted
declined
```

---

## Individual invitation

```text
Alice
│
│ invitation
▼
Bob
```

`chatId` refers to direct chat.

## Group invitation

```text
Group: Weekend Trip

Alice ──invite──► Bob
Alice ──invite──► Charlie
Alice ──invite──► David
```

Everyone has their own `ChatInvitation`.

This makes requirements 14–17 very straightforward.

---

# 9. Message

The following is a very important entity:

```text
Message
├── id
├── chatId
├── senderId
├── type
├── encryptedContent
├── mediaId
├── pollId
├── createdAt
├── editedAt
└── deletedAt
```

`type`:

```text
text
image
video
audio
poll
```

This gives us a single message pipeline:

```text
Message
│
├── text
├── image
├── video
├── audio
└── poll
```

---

# 10. Message content and deletion

Here I want to make a small but important design decision.

When the user deletes a message, **we do not delete the Message row from the database**.

Instead:

```text
deletedAt != null
```

and the client displays:

```text
Message deleted
```

The row stays in PostgreSQL. Associated Media rows are not physically removed in Phase 11. `getChatMedia` rejects deleted messages. Push notifications and audio messages are not implemented.

Same for editing:

```text
editedAt != null
```

This also helps with read/delivery states and synchronization.

---

# 11. MessageReceipt

Since the chat can be a group chat, I wouldn't put `delivered` and `read` directly in the Message.

We need user-specific receipts:

```text
MessageReceipt
├── messageId
├── userId
├── deliveredAt
└── readAt
```

In direct chat:

```text
Message
Alice → Bob

Receipt
messageId
userId = Bob
deliveredAt
readAt
```

In group chat:

```text
Message
Alice → group

Receipts:

Bob delivered ✓ read ✓
Charlie delivered ✓ read -
David delivered - read -
```

This is a much more scalable model.

---

# 12. Media

Media is separated from the Message entity.

```text
Media
├── id
├── type
├── storageKey
├── encryptedSize
├── mimeType
├── createdAt
└── ...
```

`type`:

```text
image
video
audio
```

Message contains:

```text
mediaId
```

and the actual media is in the storage system.

This means that you don't necessarily need to cram a 20 MB video blob into PostgreSQL.

Phase 8 stores **encrypted** profile pictures (≤ 5 MB) in `Media.encryptedData` as PostgreSQL `bytea`. Phase 9 stores **encrypted** chat images and videos (≤ 20 MiB) the same way. Phase 12 stores **encrypted** WAV audio (≤ 10 MiB) the same way. `storageKey` is not used.

---

# 13. Media Encryption

Pipelines:

```text
User selects video 
↓
Compress 
↓
Check ≤ 20 MB 
↓
Encrypt 
↓
Upload encrypted media 
↓
Create Media record 
↓
Create Message
```

Database:

```text
Media
storageKey = encrypted-file-reference
```

Storage:

```text
encrypted binary
```

---

# 14. Poll

Because poll is an extra requirement of the Web version, but at the same time a message type suitable for the domain:

```text
Poll
├── id
├── question
├── Anonymous
├── createdBy
└── ...
```

Options:

```text
PollOption
├── id
├── pollId
├── text
└── position
```

Votes:

```text
PollVote
├── pollId
├── optionId
├── userId
└── createdAt
```

Unique constraint:

```text
(pollId, userId)
```

This way, one user only has one active vote per poll.

Vote change:

```text
Pizza
↓
Sushi
```

update `optionId`.

Retract:

```text
DELETE PollVote
```

---

# 15. ChatMessageState / sync metadata

Because it requires:

> Messages between platforms are instantaneous.

and:

> Messages are synchronized between Web and Mobile.

We need to identify messages reliably.

`Message.id` works for this.

For example:

```text
Message ID:
01JXYZ...
```

Mobile:

```text
received message 01JXYZ
```

Web:

```text
received message 01JXYZ
```

If the realtime connection is lost:

```text
WebSocket lost
↓
reconnect
↓
request messages after last known message
↓
sync
```

So we don't need to make a separate "MobileMessage" / "WebMessage" model.

---

# 16. Realtime doesn't really need its own persistent table

For example, I wouldn't store the typing indicator in PostgreSQL.

It's a transient state:

```text
Alice is typing
```

Serverpod realtime:

```text
Alice
↓
typing event
↓
Bob
```

If Alice closes the application:

```text
event expires
```

No need to store it in the database. Phase 10 implements this as `ChatEvent` typing start/stop on MessageCentral. Clients drop a remote typist after 5 seconds without a refresh. Push notifications, audio messages, and message editing/deletion are not implemented.

Same idea for example:

```text
online
typing
temporary connection state
```

---

# 17. Domain relationships

Now the whole model can be drawn like this:

```text
User
│
├────────── 1:N ────────── Session
│
├────────── 1:N ────────── Device
│
├──────────── 1:1 ──────────── Profile
│
├──────────── 1:N ─ │
└────────── 1:N ────────── ChatInvitation

Message
│
├────────── 0:1 ─────────── Media
│
├─────────── 0:1 ─────────── Poll
│
└────────── 1:N ─ Messaging

```text
Message
MessageReceipt
Media
```

### Web extra

```text
Poll
PollOption
PollVote
```

Total **13 domain entities**.

That sounds like a lot, but considering the messenger requirements, this is actually quite compact.

---
