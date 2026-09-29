
This is very important for Web + Mobile requirements.

We use Serverpod authentication for this:

```
                   User
                    │
             Serverpod Auth
                    │
          ┌─────────┴─────────┐
          ▼                   ▼
     Android auth        Web auth
       session            session
          │                   │
       logout              active
          │                   │
          ▼                   ▼
       revoked             remains
```
   

Relation:

```
User 1 ───── N Session
```

For example:

```
User: Matti

Session A
platform: Android
revokedAt: null

Session B
platform: Web
revokedAt: null
```

If the user logs out on Android:

```
Session A
revokedAt: 2026-09-03 16:10
```

but:

```
Session B
revokedAt: null

→ Web remains logged in.
```

This directly solves the requirement:

*Logging out one device does not terminate other sessions.*

### Session ≠ Device

It is worth understanding this difference now.

Device means the place/instance where the application is used.

A session is a single logged-in session.

For example:

```
User
│
├── Device: Android phone
│ ├── Session A
│ └── Session B
│
└── Device: Firefox browser
└── Session C
```

For example, a user could log out of the browser and log back in, creating a new Session but retaining the same Device.

---