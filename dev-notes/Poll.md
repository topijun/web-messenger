
## 1. Poll is not an independent chat object

A poll is always sent as a message:
```
Message
├── type = poll
└── pollId
│
▼
Poll
```
That is, the user does not, for example, "open the poll" as a separate chat resource, but the poll is one of the chat's Message.

---
## 2. Poll

I suggest:
```
Poll
├── id
├── question
├── anonymous
├── createdBy
└── createdAt
```
`question`

The question itself:
```
"What should we eat tonight?"
```
`anonymous`

This solves the assignment requirement:
```
anonymous = false
```
→ other participants can see who voted for what.
```
anonymous = true
```
→ other users are not shown who voted for what.

Important note:

**anonymous does not mean that the system does not know the voter.**

The server still needs to know the user so that we can prevent multiple votes from the same user and allow changing the vote.

---

## 3. PollOption

Options are their own entity:
```
PollOption
├── id
├── pollId
├── text
└── position
```
For example:
```
Poll
"What should we eat?"

├── Option 1: Pizza
├── Option 2: Burgers
└── Option 3: Sushi
```
It is worth keeping the `position` so that the order of the options does not depend on the order in which they are returned in the database.

---

## 4. PollVote

Voting needs its own entity:
```
PollVote
├── id
├── pollId
├── optionId
├── userId
└── createdAt
```
Relationships:
```
Poll
├── 1:N PollOption
└── 1:N PollVote

User
└── 1:N PollVote
```
---

## 5. One user → one active vote

This is an important constraint.

A user can vote for:
```
Poll #10
↓
User Alice
↓
Option Pizza
```
But not for:
```
Alice
├── Pizza
├── Burgers
└── Sushi
```
if our poll is a single-option poll.

Therefore:
```
UNIQUE(pollId, userId)
```
The database prevents another active vote by the same user.

---

## 6. Changing a vote

Assignment requires that the user can change their vote.

No new Vote row is needed for this.

For example:
```
PollVote
userId = Alice
pollId = 10
optionId = Pizza
```
Alice changes her mind:
```
optionId = Burgers
```
That is:
```
Pizza
↓
Burgers
```
The `PollVote` remains the same.

This is more elegant than deleting the old vote and creating a new one.

---

## 7. Withdrawing a vote

Assignment also requires a vote retract function.

The simplest solution here is:
```
DELETE PollVote
```
When Alice withdraws:
```
PollVote
Alice → Burgers
```
is deleted.

The poll itself remains:
```
Poll
├── Pizza
├── Burgers
└── Sushi
```
but Alice has not voted for anything anymore.

This is much clearer from a domain perspective than, for example:
```
active = false
```
Because all we need is:

> Vote row exists = user has an active vote.

---

## 8. Anonymous poll

Here is an important difference between the database and the user interface.

In the database:
```
PollVote
├── userId = Alice
└── optionId = Pizza
```
so the server knows the voter.

But in the UI:

#### Public poll
```
Pizza 3 votes
	Alice
	Bob
	Charlie

Burgers 2 votes
	David
	Eve
```
#### Anonymous poll
```
Pizza 3 votes
Burgers 2 votes
```
No user list.

This also allows for:

- one vote per user
- changing votes
- cancelling votes
- calculating results

without having to make a separate "anonymous vote" model.

---
## 9. Do we need closedAt?

This is the first point where I would like to add a feature that assignment does not require.

For example:
```
Poll
├── ...
└── closedAt
```
Then the poll could be:
```
open
closed
```
But I would not add it now.

Assignment requires:

- public/anonymous
- vote
- change vote
- retract vote

It doesn't require closing the poll.

A simpler domain is better here.

---
## 10. Do we need a `multipleChoice` field?

Same thing.

We could do:
```
multipleChoice = true/false
```
but the assignment doesn't require it.

If the intention is one vote per user, the current:
```
UNIQUE(pollId, userId)
```
is perfect.

If later we want multiple choice polls, the domain should be extended.

**Don't do it now.**

---

## 11. Poll lifecycle

The whole thing is now very clear:
```
Create Poll
│
▼
Create PollOptions
│
▼
Create Message
│
▼
Users vote
│
├── vote
├── change vote
└── retract vote
```
For example:
```
Alice creates:

"What should we eat?"

Pizza
Burgers
Sushi
```
Message:
```
Message
type = poll
pollId = 42
```
Poll:
```
Poll #42
question = "What should we eat?"
anonymous = false
createdBy = Alice
```
Options:
```
1 → Pizza
2 → Burgers
3 → Sushi
```
Alice:
```
PollVote
Alice → Pizza
```
Bob:
```
PollVote
Bob → Sushi
```
Bob changes:
```
Bob → Pizza
```
and finally:
```
Bob retracts vote
```
→ Bob's `PollVote` is deleted.

---

## 🔒 Lock Poll-domain

I think the final first version is:
```
Poll
├── id
├── question
├── anonymous
├── createdBy
└── createdAt
```

```
PollOption
├── id
├── pollId
├── text
└── position
```

```
PollVote
├── id
├── pollId
├── optionId
├── userId
└── createdAt
```
Relations:
```
Message 0..1 ─── 1 Poll
                    │
                    ├── 1:N PollOption
                    │
                    └── 1:N PollVote
                              │
                              ▼
                             User
```
Constraint:

UNIQUE(pollId, userId)

and user actions:

Vote
→ create PollVote

Change vote
→ update optionId

Retract vote
→ delete PollVote

---

## Now the domain model looks like this:

```
User
 ├── Profile
 ├── Device
 ├── ChatParticipant
 ├── ChatInvitation
 ├── Message
 └── PollVote

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