

Profile is the user's presentation and visual identity:

```
Profile
├── userId
├── aboutMe
├── profileImageId
├── createdAt
└── updatedAt
```

Relation:
```
User 1 ───── 1 Profile
```
userId also serves as the identifier for the Profile object.

Important simplification:

The default profile picture does not need to be stored in the database.

We can do:

```
profileImageId == null
↓
Flutter displays the default profile picture
```

When the user uploads their own picture:

```
profileImageId != null
↓
the user's picture is displayed
```

This saves one unnecessary Media row for each user.

Phase 8: JPEG and PNG, 5 MB max (original bytes). The server encrypts the file with AES-256-GCM (same `applicationEncryptionKey` as Phase 7) and stores ciphertext in `Media.encryptedData` (`bytea`). This is application-layer encryption, not E2EE. Flutter Add/Change photo uses the system file picker (Android, iOS, Web).

---
