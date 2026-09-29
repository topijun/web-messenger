
Device and Serverpod's auth token are not the same thing.

```
User
│
├── Device A
│   └── Android phone
│
├── Device B
│   └── Firefox browser
│
└── Device C
    └── another browser/device
```

Serverpod authentication takes care of whether the user is logged in.
Our Device tells us where push notifications can be sent.
This way, responsibilities remain clear.

```
Authentication / login sessions
        │
        └── Serverpod Auth
             NOT our domain model
```

For push notifications, I would keep this separate:

```
Device
├── id
├── userId
├── platform
├── pushToken
├── createdAt
└── lastSeenAt
```

Relation:

```
User 1 ───── N Device
```

For example:

```
User
├── Device A
│ └── Android
│
├── Device B
│ └── Web browser
│
└── Device C
└── iPhone
```

This will become important later when the server has to decide:

To which devices should a push notification be sent for this new message?