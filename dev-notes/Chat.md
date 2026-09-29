
## 1. Chat Model

```
Chat
├── id
├── type
├── name
├── createdAt
├── updatedAt
└── lastMessageAt
```

where:

```
type = direct | group
```

So that:

```
Chat
   │
   ├── type: direct
   │
   └── Participants
       ├── Alice
       └── Bob
```

or:

```
Chat
   │
   ├── type: group
   ├── name: "Weekend trip"
   │
   └── Participants
       ├── Alice
       ├── Bob
       ├── Charlie
       └── David
```

---

## 2. ChatParticipant

Membership is not directly put into Chat, for example as a list of user IDs.

Instead, a join entity is used:

```
ChatParticipant
├── id
├── chatId
├── userId
├── role
├── joinedAt
├── archived
└── notificationsMuted
```

Relationships: 

```
User 1 ───── N ChatParticipant N ───── 1 Chat
```

In practice:

```
Chat
│
├── ChatParticipant
│ └── Alice
│
├── ChatParticipant
│ └── Bob
│
└── ChatParticipant
└── Charlie
```
This gives us one very important feature:

Chat settings are user-specific

For example:

```
Alice
archived = true

Bob
archived = false
```

The same chat can be archived for Alice but active for Bob.

Same goes for:

```
notificationsMuted
```

This is exactly the right place for this information.

---

## 3. Role

Let's keep the role model simple:

```
role = admin | member
```

In the group:

```
Weekend trip

Alice admin
Bob member
Charlie member
David member
```

Admin is needed in practice for group features.

For example, later:

- changing the group name
- managing members
- managing invitations

I wouldn't add the `owner` role yet.

`admin | member` is sufficient for the assignment requirements and doesn't tie us to a more complicated permission system.

---

## 4. ChatInvitation

Invitations are kept as their own entity:

```
ChatInvitation
├── id
├── chatId
├── senderId
├── receiverId
├── status
└── createdAt
```
```
status =
pending
accepted
declined
```

For example:

```
Alice
│
│ invitation
▼
Bob
```

is stored as:

```
ChatInvitation
chatId = 123
senderId = Alice
receiverId = Bob
status = pending
```

---

## 5. Creating a Direct Chat

When Alice finds Bob and presses Send invitation, we don't necessarily need an active conversation yet.

A better lifecycle is:

```
User search
│
▼
Send invitation
│
▼
ChatInvitation
│
├── declined ──→ end
│
└── accepted
│
▼
Create Chat
```

That is:

**the conversation only starts when the invitation is accepted.**

This makes the state clear.

---

## 6. Group Invitation

The same mechanism works for a group.

For example, Alice creates a group:

```
Chat
type = group
name = "Project Team"
```

Alice:

```
ChatParticipant
role = admin
```

Bob is sent:

```
ChatInvitation
sender = Alice
receiver = Bob
chat = Project Team
```

Bob accepts:

```
ChatInvitation.status = accepted
```

and then:

```
ChatParticipant
chatId = Project Team
userId = Bob
role = member
```

This is a very good reason why we have one common ChatInvitation template.

---

## 7. Who Can Invite?

Here I propose a simple rule:

### Direct chat

Any user can send another user an invitation.

```
Alice → Bob
```
### Group chat

Only the group admin can invite new members.
```
Alice (admin)
│
├──→ Bob
├──→ Charlie
└──→ David
```
This gives us a clear permission model without any extra tables.

---
## 8. What happens when a member leaves?

It's worth distinguishing two things here.

### Archive

The user just wants to hide the conversation: 
```
archived = true
```

The chat and membership are preserved.

### Leave group

The user leaves the group.

Then the `ChatParticipant` is deleted or marked as left.

Since the assignment does not require a full audit of the chat history, I would keep this simple:

```
DELETE ChatParticipant
```
The messages are preserved:
```
Chat
├── Message
├── Message
└── Message
```

and the rest of the chat history is not lost just because one member leaves.

This can be refined later when we process messages.

---

## 9. Important constraint for direct chat

We don’t want Alice and Bob to accidentally get:

```
Chat #1
Alice + Bob

Chat #2
Alice + Bob
```

unless there is a deliberate reason for it.

Therefore, application logic is needed later for direct chat:

```
find existing direct chat
between Alice and Bob

if exists:
	use it
else:
	create it
```

At the database level, this can be difficult to express directly with a regular unique constraint, because the members are ChatParticipant rows.

Let’s solve this with domain/business logic rather than trying to forcefully make the database model too complex.

---
## 10. Final Chat Entity

At this point, our model looks like this:

                         ┌──────────────┐
                         │     User     │
                         └──────┬───────┘
                                │
                                │ 1:N
                                ▼
                       ┌──────────────────┐
                       │ ChatParticipant  │
                       ├──────────────────┤
                       │ id               │
                       │ chatId           │
                       │ userId           │
                       │ role             │
                       │ joinedAt         │
                       │ archived         │
                       │ notificationsMuted│
                       └────────┬─────────┘
                                │
                                │ N:1
                                ▼
                         ┌─────────────┐
                         │    Chat     │
                         ├─────────────┤
                         │ id          │
                         │ type        │
                         │ name        │
                         │ createdAt   │
                         │ updatedAt   │
                         │ lastMessageAt│
                         └─────────────┘
                                ▲
                                │
                                │
                       ┌────────┴─────────┐
                       │ ChatInvitation  │
                       ├──────────────────┤
                       │ id               │
                       │ chatId           │
                       │ senderId         │
                       │ receiverId       │
                       │ status           │
                       │ createdAt        │
                       └──────────────────┘
                       ```               

and user connections:

```
User
 ├── 1:N ChatParticipant
 │
 ├── 1:N ChatInvitation (sender)
 │
 └── 1:N ChatInvitation (receiver)
```