
There is one fundamental design decision we should make immediately:

**Everything displayed in a chat is a Message object, but a Message can contain different types of content.**

This means we do not create separate models such as TextMessage, ImageMessage, AudioMessage, VideoMessage, etc.

[[Poll]]

---
## 1. Message

I propose:

```
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

Types:

```
text
image
video
audio
poll
```

Relationships:
```
Chat 1 ───── N Message
User 1 ───── N Message
```

So conceptually:
```
Chat
 │
 ├── Message
 │    ├── sender = Alice
 │    ├── type = text
 │    └── ...
 │
 ├── Message
 │    ├── sender = Bob
 │    ├── type = image
 │    └── ...
 │
 └── Message
      ├── sender = Alice
      ├── type = audio
      └── ...
```

I believe this is the right abstraction.

---
## 2. Why encryptedContent?

The assignment requires messages to be encrypted before they are stored in the database.

We do not want:

```
Message
content = "Hello Bob!"
```

Instead, conceptually:

```
Message
encryptedContent = "a8f4c91d..."
```

In Flutter:

```
User writes message
        ↓
encrypt
        ↓
send ciphertext
        ↓
Serverpod
        ↓
PostgreSQL
```

When the message is received:

```
PostgreSQL
    ↓
ciphertext
    ↓
Flutter
    ↓
decrypt
    ↓
"Hello Bob!"
```

The exact encryption architecture should be designed as a separate concern. We should not lock down the algorithm or key-management strategy at this stage.

Phase 7 implements **server-side AES-256-GCM** for `encryptedText` (application-layer, not E2EE). The Flutter client still sends and receives plaintext through the API. PostgreSQL stores only ciphertext.

Phase 9 implements image and video messages by referencing `Media` (`Message.mediaId`). Original bytes are encrypted with `encryptBytes` and stored in `Media.encryptedData`.

Phase 12 implements audio messages the same way (`Message.type = audio`, WAV, max 10 MiB). Realtime and history expose metadata only.

Phase 10 typing indicators use the existing `ChatEvent` stream (`typingStarted` / `typingStopped`). They are not Messages, are not persisted in PostgreSQL, do not update `Chat.lastMessageAt`, and never include composer text. Authorization is chat membership. Flutter idle-stop is 1.5s; heartbeat refresh is 2s; remote client expiry is 5s.

Phase 11 message edit/delete uses the existing `Message.editedAt` / `Message.deletedAt` columns (soft delete; no new table). Only the original sender may edit text messages or delete their own text/image/video/audio messages. Edits re-encrypt plaintext with a fresh AES-GCM nonce. Deleted APIs return empty `encryptedText` and never decrypt the original body. Associated `Media` rows are not physically removed; `getChatMedia` rejects deleted messages. Realtime uses `messageEdited` / `messageDeleted` on the existing watch stream. Push notifications and email search are not implemented yet.


---
## 3. What about image/video/audio?

These should not be stored directly inside the Message object.

Instead:

```
Message
    │
    └── mediaId ─────→ Media
```

For example:

```
Message
type = image
mediaId = 782
```

And:

```
Media
type = image
storageKey = ...
mimeType = image/jpeg
...
```

This allows Message to communicate:

> "This is an image message."

While Media communicates:

> "These are the details of the actual file."

---
## 4. Polls follow the same idea

A poll should not be embedded directly into Message as a complete structure either.

```
Message
type = poll
pollId = 42
```

→

```
Poll
├── question
├── anonymous
└── ...
```

→
```
PollOption
├── option A
├── option B
└── option C
```

This keeps Message lightweight.

---
## 5. MessageReceipt

This is particularly important for group chats.
```
MessageReceipt
├── messageId
├── userId
├── deliveredAt
└── readAt
```

Relationships:
```
Message 1 ───── N MessageReceipt
User    1 ───── N MessageReceipt
```
### Direct chat

Alice sends Bob a message:
```
Message #100
sender = Alice
```

Bob gets:
```
MessageReceipt
messageId = 100
userId = Bob

deliveredAt = 10:30:02
readAt      = 10:30:05
```

Alice can therefore see:
```
✓   sent
✓✓  delivered
✓✓  read
```

---
## 6. This becomes especially useful in group chats

In a group:
```
Alice → Message #100

Recipients:
Bob
Charlie
David
```

We can have:
```
MessageReceipt
├── Bob
│   deliveredAt ✓
│   readAt       ✓
│
├── Charlie
│   deliveredAt ✓
│   readAt       null
│
└── David
    deliveredAt ✓
    readAt       ✓
```

This is significantly better than trying to put something like:
```
delivered = true
read = true
```

directly on Message.

A group message does not have a single delivered or read state.

---
## 7. Message lifecycle

There are essentially three separate states:
```
created
   ↓
delivered
   ↓
read
```

These should not be conflated.

### Sent

The message has been created on the server:

```
createdAt != null
```

### Delivered

The recipient's client has received the message:

```
deliveredAt != null
```

### Read

The recipient has opened or seen the message:
```
readAt != null
```

---
## 8. Failed delivery

There is a small but important domain decision here.

I would not store a failed state on Message.

For example, a network failure:
```
User
 ↓
send
 ↓
network failure
```

is primarily a client-side sending/synchronization state.

It does not mean that the database should contain:
```
Message.status = failed
```

A better model is:
```
local outgoing message
        ↓
sending
        ↓
success → server message
        ↓
failure → UI shows failed
```

The client can provide:

> Retry

and attempt to send the same message again.

This is where Message.id, or a separate client-generated identifier, will later become important for idempotency.

---
## 9. Edit

The assignment requires users to be able to edit their own messages.

Therefore:
```
editedAt
```

is sufficient.

For example:
```
createdAt = 12:00
editedAt  = 12:05
```

The original message content is replaced with the new content.

Only the sender can edit, and only `type == text` messages. A deleted message cannot be edited. `editedAt` is the server clock. Receipts and `Chat.lastMessageAt` are unchanged. The new body is encrypted with a fresh AES-256-GCM nonce before PostgreSQL update.

The UI can display:
```
Hello Bob! (edited)
```

Since the content is encrypted, the new content must also be stored encrypted.

---
## 10. Delete

I would not physically delete the Message row.

Instead, use a soft delete:
```
deletedAt
```

For example:
```
deletedAt = 12:10
```

The UI can then display:
```
Message deleted
```

The `Message` row stays in PostgreSQL so ids, order, receipts, and `mediaId` remain stable. The associated `Media` row is not physically deleted in this phase. `getChatMedia` rejects a deleted message so original bytes are not returned. History still includes the row, with empty display text and `deletedAt` set.

Instead of:
```
DELETE FROM Message
```

Why?

Because a message may have:

- receipts
- media
- a poll
- data related to auditing
- synchronization requirements for other clients

Soft deletion makes these cases significantly easier to handle.

---
## 11. What about a deleted image or video?

Here we should keep the following relationship separate:
```
Message
    ↓
Media
```

The Message can be marked:
```
deletedAt != null
```

The associated media can potentially be garbage-collected later if it is no longer needed.

However, we should not implement automatic media deletion yet. That belongs to the Media/storage phase.

---
## 12. Realtime is not a Message field

This is an important architectural distinction.

When Alice sends a message:
```
Flutter
   ↓
Serverpod
   ↓
PostgreSQL
   ↓
realtime event
   ↓
Bob's Flutter
```

Realtime is therefore a messaging mechanism, not a property of Message.

The same applies to typing indicators:
```
Alice is typing...
```

This should not be stored in PostgreSQL.

It is a transient realtime event:
```
Alice
   ↓
typing:start
   ↓
Bob
```

and:
```
typing:stop
```

This saves us from storing a lot of unnecessary database data.

---
## 13. Final Message domain

The domain now looks like this:
```
                         ┌──────────────┐
                         │     Chat     │
                         └──────┬───────┘
                                │
                                │ 1:N
                                ▼
                         ┌─────────────┐
                         │   Message   │
                         ├─────────────┤
                         │ id          │
                         │ chatId      │
                         │ senderId    │
                         │ type        │
                         │ encryptedContent
                         │ mediaId     │
                         │ pollId      │
                         │ createdAt   │
                         │ editedAt    │
                         │ deletedAt   │
                         └──────┬──────┘
                                │
                ┌───────────────┼───────────────┐
                │               │               │
                ▼               ▼               ▼
             Media            Poll       MessageReceipt
                                            │
                                            │
                                            ▼
                                           User
```

And:
```
Message.type

text
image
video
audio
poll
```

---

## 🔒 Locking the Message domain

At this stage, I propose that the following decisions are now locked:

### Message
One Message model for all message types.
type determines the content type.
Text content is stored encrypted.
Media is referenced through the Media entity.
Polls are referenced through the Poll entity.
editedAt indicates that the message has been edited.
deletedAt enables soft deletion.
### MessageReceipt
One receipt per user per message.
deliveredAt.
readAt.
Works for both direct and group chats.
### Realtime
New messages are delivered through the realtime channel.
Typing indicators are transient.
Typing status is not stored in the database.
### Delivery
```
created → delivered → read
```
### Failed
No persistent failed field on Message.
The client handles failed sending and retrying.

---

The domain now has three clear layers:
```
USER
User
 ├── Profile
 └── Device

CHAT
Chat
 ├── ChatParticipant
 └── ChatInvitation

MESSAGING
Message
 ├── MessageReceipt
 ├── Media
 └── Poll
```

