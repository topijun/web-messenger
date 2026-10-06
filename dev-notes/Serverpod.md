
Look at [[What is Serverpod?]] for info about what it is.

# 1. `messenger_user.spy.yaml`

First important clarification: **we are not creating our own `User` table**, but rather a connection between Messenger's user profile/domain data and Serverpod Auth's `AuthUser` model.

This corresponds to Serverpod's recommended bridge-table solution for our own data related to AuthUser. ([Serverpod][2])

```yaml
class: MessengerUser
table: messenger_user

fields:
authUser: module:serverpod_auth_core:AuthUser?, relation(onDelete=Cascade)

username: String, unique

createdAt: DateTime, default=now
updatedAt: DateTime, default=now
```

### Why is this?

```text
AuthUser
│
│ 1 ─ 1
▼
MessengerUser
```

Serverpod Auth owns the authentication identity.

`MessengerUser` owns the Messenger domain identity.

### `username`

I'm keeping the username at MessengerUser at this point because:

* it has to be unique
* it's used for user search
* it's Messenger's own domain concept

**Email comes from AuthUser** and isn't copied to us.

This avoids having to maintain two email addresses.

---

# 2. `profile.spy.yaml`

```yaml
class: Profile
table: profile

fields:
user: MessengerUser?, relation(onDelete=Cascade)

aboutMe: String?
profileImage: Media?, relation(optional, onDelete=SetNull)

createdAt: DateTime, default=now
updatedAt: DateTime, default=now

indexes:
profile_user_idx:
fields: userId
unique: true
```

This creates:

```text
MessengerUser 1 ─ 1 Profile
```

and:

```text
Profile ──> Media
```

`profileImage` is nullable, because the application's own default avatar image can be used as the default.

### One important thing

This creates a dependency:

```text
Profile → Media
```

but `Media` only indirectly refers to Message later.

This is a perfectly possible structure, but since `Media` is primarily intended as an attachment to messages, **I really wouldn't want to mix the profile image with the same Media model**.

Therefore, I propose a small change to the original domain model:

> `Media` can technically serve both message media and profile picture.

It saves one entity, but makes the Media model a bit more general.

Let's keep this in the plan on purpose.

---

# 3. `device.spy.yaml`

```yaml
class: Device
table: device

fields:
user: MessengerUser?, relation(onDelete=Cascade)

platform: DevicePlatform
pushToken: String?
createdAt: DateTime, default=now
lastSeenAt: DateTime
```

Enum:

```yaml
class: DevicePlatform

values:
- android
- ios
- web
```

Structure:

```text
MessengerUser
├── Device
├── Device
└── Device
```

One user can be logged in to multiple clients.

This is important for the requirement:

> Mobile and web can be logged in at the same time.

`Device` is not an authentication session. Serverpod Auth handles the session/token.

---

# 4. `chat.spy.yaml`

```yaml
class: Chat
table: chat

fields: 
type: ChatType 
name: String? 

createdAt: DateTime, default=now 
updatedAt: DateTime, default=now 
lastMessageAt: DateTime?
```

enum:

```yaml
class: ChatType

values: 
- direct 
- group
```

### Why is `name` nullable?

Direct chat:

```text
name = null
```

Group:

```text
name = "Weekend trip"
```

We don't need:

```text
DirectChat
GroupChat
```

separate models.

---

# 5. `chat_participant.spy.yaml`

```yaml
class: ChatParticipant
table: chat_participant

fields: 
chat: Chat?, relation(onDelete=Cascade) 
user: MessengerUser?, relation(onDelete=Cascade) 

role: ChatParticipantRole 
joinedAt: DateTime, default=now 
archived: bool, default=false 
notificationsMuted: bool, default=false

indexes: 
chat_participant_unique_idx: 
fields: chatId, userId 
unique: true 

chat_participant_user_idx: 
fields: userId
```

enum:

```yaml
class: ChatParticipantRole

values: 
- admin 
- member
```

This is a very central board.

```text
Chat
│
├── Participant → User A
├── Participant → User B
└── Participant → User C
```

And at the same time:

```text
archived
notificationsMuted
```

are **user-specific**.

That's exactly what we need.

---

# 6. `chat_invitation.spy.yaml`

```yaml
class: ChatInvitation
table: chat_invitation

fields:
chat: Chat?, relation(onDelete=Cascade)

sender: MessengerUser?, relation(name=invitation_sender, onDelete=Cascade)
receiver: MessengerUser?, relation(name=invitation_receiver, onDelete=Cascade)

status: ChatInvitationStatus
createdAt: DateTime, default=now

indexes:
chat_invitation_receiver_status_idx:
fields: receiverId, status

chat_invitation_sender_idx:
fields: senderId
```

Enum:

```yaml
class: ChatInvitationStatus

values:
- pending
- accepted
- declined
```

Here `sender` and `receiver` both point to `MessengerUser`.

They are given different relation names because they are two different relations for the same model.

---

# 7. `message.spy.yaml`

Here comes one small but important decision:

**`encryptedContent` → `encryptedText`.**

```yaml
class: Message
table: message

fields:
chat: Chat?, relation(onDelete=Cascade)
sender: MessengerUser?, relation(onDelete=Restrict)

type: MessageType

encryptedText: String?

media: Media?, relation(optional, onDelete=SetNull)
poll: Poll?, relation(optional, onDelete=SetNull)

createdAt: DateTime, default=now
editedAt: DateTime?
deletedAt: DateTime?

indexes: 
message_chat_created_idx: 
fields: chatId, createdAt 

message_sender_idx: 
fields: senderId
```

enum:

```yaml
class: MessageType

values: 
- text 
- image 
- video 
- audio 
- poll
```

### Why is `encryptedText` nullable?

Because:

```text
text → encryptedText
image → media
video → media
audio → media
poll → poll
```

Not all messages have text content.

---

# 8. `message_receipt.spy.yaml`

```yaml
class: MessageReceipt
table: message_receipt

fields: 
message: Message?, relation(onDelete=Cascade) 
user: MessengerUser?, relation(onDelete=Cascade) 

deliveredAt: DateTime? 
readAt: DateTime?

indexes: 
message_receipt_unique_idx: 
fields: messageId, userId 
unique: true 

message_receipt_user_idx: 
fields: userId
```

This gives:

```text
Message 
├── Receipt → User A 
├── Receipt → User B 
└── Receipt → User C
```

No receipt line is created for the sender.

---

# 9. `media.spy.yaml`

```yaml
class: Media
table: media

fields:
type: MediaType

storageKey: String
mimeType: String
size: int
encryptedSize: int

createdAt: DateTime, default=now
deletedAt: DateTime?
```

Enum:

```yaml
class: MediaType

values:
- image
- video
- audio
```

This is intentionally **metadata plus encrypted bytes** for profile pictures and chat image/video.

Serverpod 3.4.13 `ByteData` maps to PostgreSQL `bytea`. `Media.encryptedData` holds AES-256-GCM ciphertext, not the original file. File/object storage (`storageKey`) is unused. Audio messages reuse the same `Media` row (WAV, max 10 MiB).


---

# 10. `poll.spy.yaml`

```yaml
class: Poll
table: poll

fields: 
question: String 
anonymous: bool, default=false 

createdBy: MessengerUser?, relation(onDelete=Restrict) 

createdAt: DateTime

indexes: 
poll_created_by_idx: 
fields: createdById
```

For example:

```text
"Which day works best?"
Anonymous = false
```

or:

```text
"Which design do you prefer?"
Anonymous = true
```

Please note that **anonymous does not mean that we do not record the user**.

`PollVote.user` is needed so that:

* the user can change their vote
* the user can cancel their vote
* the same user cannot vote twice

Anonymity is therefore above all **the rule of the information displayed in the user interface**.

---

# 11. `poll_option.spy.yaml`

```yaml
class: PollOption
table: poll_option

fields:
poll: Poll?, relation(onDelete=Cascade)

text: String
position: int

indexes:
poll_option_order_idx:
fields: pollId, position
```

For example:

```text
Poll
├── Option 0 → Monday
├── Option 1 → Tuesday
└── Option 2 → Wednesday
```

`position` preserves the original order of the options.

---

# 12. `poll_vote.spy.yaml`

```yaml
class: PollVote
table: poll_vote

fields: 
poll: Poll?, relation(onDelete=Cascade) 
option: PollOption?, relation(onDelete=Cascade) 
user: MessengerUser?, relation(onDelete=Cascade) 

createdAt: DateTime

indexes: 
poll_vote_unique_idx: 
fields: pollId, userId 
unique: true 

poll_vote_option_idx: 
fields: optionId
```

The main constraint:

```text
UNIQUE(pollId, userId)
```

Or:

```text
User A → Poll 1 → Option B
```

but not:

```text
User A → Poll 1 → Option B
User A → Poll 1 → Option C
```

To change the sound is:

```text
UPDATE PollVote.option
```

and cancellation:

```text
DELETE PollVote
```

---

# Entire file structure

These consist of, for example:

```text
server/
└── lib/
└── src/
└── models/
├── messenger_user.spy.yaml
├── profile.spy.yaml
├── device.spy.yaml
├── chat.spy.yaml
├── chat_participant.spy.yaml
├── chat_invitation.spy.yaml
├── message.spy.yaml
├── message_receipt.spy.yaml
├── media.spy.yaml
├── poll.spy.yaml
├── poll_option.spy.yaml
└── poll_vote.spy.yaml
```

Enums can be in these same files, so we don't need separate files for them.

---

# Relations as a whole

When all are combined:
```
                         AuthUser
                            │
                            │ 1:1
                            ▼
                    ┌────────────────┐
                    │ MessengerUser  │
                    └───────┬────────┘
                            │
             ┌──────────────┼──────────────┐
             │              │              │
             ▼              ▼              ▼
          Profile         Device       ChatParticipant
             │                             │
             │                             │
             ▼                             ▼
           Media                         Chat
                                            │
                              ┌─────────────┼─────────────┐
                              │             │             │
                              ▼             ▼             ▼
                         Participant   Invitation      Message
                                                          │
                                    ┌─────────────────────┼──────────────┐
                                    │                     │              │
                                    ▼                     ▼              ▼
                               Receipt                  Media          Poll
                                                                         │
                                                                ┌────────┴────────┐
                                                                ▼                 ▼
                                                           PollOption         PollVote
```

but we need to design our own anonymization/deletion policy for deleting the user later.

`Restrict` forces us to do it consciously.

Serverpod's `Cascade`, `Restrict`, `NoAction` and `SetNull` correspond to the referential-action behavior of the database. ([Serverpod][3])

---
# Delete Strategy

You should lock this down at this point.

| Parent | Child | Behavior |
| ------------- | -------------- | -------------- |
| AuthUser | MessengerUser | **Cascade** |
| MessengerUser | Profile | **Cascade** |
| MessengerUser | Device | **Cascade** |
| MessengerUser | ChatParticipant | **Cascade** |
| Chat | ChatParticipant | **Cascade** |
| Chat | ChatInvitation | **Cascade** |
| Chat | Message | **Cascade** |
| Message | MessageReceipt | **Cascade** |
| Poll | PollOption | **Cascade** |
| Poll | PollVote | **Cascade** |
| MessengerUser | Message.sender | **Restrict** |
| MessengerUser | Poll.createdBy | **Restrict** |

The last two are intentional.

If a user is deleted, we don't want to accidentally do:

```text
delete User
→ delete all messages
```

but we need to design our own anonymization/deletion policy for deleting the user later.

`Restrict` forces us to do it consciously.

Serverpod's `Cascade`, `Restrict`, `NoAction` and `SetNull` correspond to the referential-action behavior of the database. ([Serverpod][3])

---
# One thing I would change before implementing

Looking at the model as a whole now, I see one potential problem:

```text
Profile
│
└── Media
```

but:

```text
Message
│
└── Media
```

so `Media` serves two different purposes.

That is **not wrong**, and with current requirements it is even a simpler solution. But then Media is actually:

> "An encrypted file stored by the application"

and not "message attachment".

I currently prefer this to adding a new `ProfileImage` entity. It still keeps the domain in 12 models.

---

# Final check

These models cover all current requirements:

| Requirement | Model |
| ------------------ | ------------------------------------ |
| user | `MessengerUser` + Serverpod Auth |
| email/password | Serverpod Auth |
| email verification | Serverpod Auth |
| password recovery | Serverpod Auth |
| profile | `Profile` |
| profile picture | `Media` |
| multiple devices | `Device` |
| direct chat | `Chat(type=direct)` |
| group chat | `Chat(type=group)` |
| membership | `ChatParticipant` |
| Archive | `ChatParticipant.archived` |
| mute | `ChatParticipant.notificationsMuted` |
| invitations | `ChatInvitation` |
| text | `Message` |
| image/video/audio | `Message` + `Media` |
| edit | `Message.editedAt` |
| delete | `Message.deletedAt` |
| delivered/read | `MessageReceipt` |
| poll | ``Poll'' |
| poll options | `PollOption` |
| votes | `PollVote` |
| anonymous voting | `Poll.anonymous` |
| vote change | `PollVote.option` |
| vote retract | `PollVote` delete |
| message ordering | `Message.createdAt` |
| chat sorting | `Chat.lastMessageAt` |

And intentionally **no database models**:

```text
Session → Serverpod Auth
TypingIndicator → realtime
OnlineStatus → realtime
MessageStatus → client/realtime
SearchResult → client-side
```

I think this is now a very good starting point for the actual Serverpod implementation.