
As we will use Serverpod of authentication, the Serverpod  Auth owns the basic identity of the authenticated user.

The current recommendation for Serverpod 3.x is to create your own domain table that is associated with the serverpod_auth_core:AuthUser template.

```
Serverpod Auth
      │
      │ 1 ─ 1
      ▼
MessengerUser
      │
      ├── Profile
      ├── Device
      ├── ChatParticipant
      ├── ChatInvitation
      ├── Message
      └── PollVote
```

---

## What does Auth do?

#### Serverpod:

- authentication
- password
- authentication tokens
- session persistence
- login/logout
- token refresh
- authentication state
- user auth identity
- basic things like username/profile picture enabling auth data

Serverpod's auth module is specifically intended for this.

### What does MessengerUser do?

Our domain:
```
MessengerUser
├── authUser
├── username? ← if we need our own messenger username
├── createdAt
└── updatedAt
```


> AuthUser is the source of the user's identity. MessengerUser only contains domain-specific information for the Messenger application.






---

## Legacy User Model **--do not use--**

Let's keep User as pure as possible as an account and identity:

```
User
├── id
├── email
├── username
├── passwordHash
├── emailVerifiedAt
├── createdAt
└── updatedAt
```
A few important decisions:

- `passwordHash` → the password is never stored as is.
- `emailVerifiedAt` is better than `emailVerified: bool` in my opinion.
	- `null` = not verified
	- timestamp = verified
- `email` and `username` are user identification data, not Profile data.
- Both must be unique.
- Registration can first create a user in unverified mode, but login/actual use is blocked before email verification.

This gives us, for example:

```
User #42
email: matti@example.com
username: Matti
emailVerifiedAt: 2026-09-03 14:32
```

---
 