# Requirements — Mobile Messenger (Mobile App Development)

  

1. Repository contains complete source code and configuration files

  

2. Documentation (README) includes all required sections

Check presence of:

- Project overview

- Complete setup instructions

- Usage guide

  

3. Application runs successfully on a virtual or physical device with chosen platform (Android/iOS).

  

4. User can create an account with email, username and password ✅

  

5. Registration is not allowed if email or username is already in use

Verify that user receives proper visual feedback

  

6. Application checks the password strength ✅

Password should contain:

- at least 8 characters

- at least 1 lowercase letter

- at least 1 uppercase letter

- at least 1 digit

- at least 1 special character

  

7. Registration is not allowed if password does not pass strength check ✅

Verify that user receives proper visual feedback

  

8. User receives verification email after creating an account ✅

Email IDP registration callback sends the verification code through Gmail SMTP.
The code is entered in the app. SMTP credentials stay in gitignored
`config/passwords.yaml`.

  

9. User needs to provide email and password to log in to the messenger ✅

  

10. User can reset their account's password ✅

Login → Forgot password → Email IDP start/verify/finish → login with the new password.
Reset codes are emailed through the same Gmail SMTP hook as registration.
Unknown emails still do not send mail (Email IDP non-enumeration).

  

11. Application features user authentication persistence, unless they explicitly log out or their session expires ✅

Verify that by closing and reopening the application. User should stay logged in.

  

12. User has a profile page within an application ✅

Verify that the profile page features at least a username, a profile picture, and About Me sections

  

13. User has a default profile picture upon first log in to the application ✅

  

14. Application supports uploading a profile picture at least in JPEG and PNG formats ✅

Phase 8: JPEG and PNG only. Server checks magic bytes, not the filename. Maximum original size is 5 MB (inclusive). Stored `Media.encryptedData` is AES-256-GCM ciphertext, not the original file.

  

15. User can edit any data in their profile  ✅

  

16. User can search for contacts by username or by email ✅

  

17. User can send chat invitations to other users  ✅

  

18. User can accept or decline the chat invitations  ✅

  

19. Application has a pending invitation section  ✅

  

20. Application has a chat list sorted by the time of the last message received or sent ✅

  

21. Application allows user to archive and unarchive chats  ✅

  

22. Users are able to send text messages to each other  ✅

  

23. Users are able to send images to each other  ✅

Phase 9: JPEG and PNG, max 20 MiB original bytes. Server checks magic bytes. Stored `Media.encryptedData` is AES-256-GCM ciphertext. Realtime events carry `mediaId` only; Flutter loads bytes with `getChatMedia`.

24. Users are able to send videos to each other  ✅

Phase 9: MP4 and WebM, max 20 MiB original bytes. Same encryption and retrieval rules as images.

25. Chat has typing indicators showing whether either user is typing a message in real time  ✅

Phase 10: transient `ChatEvent` (`typingStarted` / `typingStopped`) on the existing watch stream. Not stored in PostgreSQL. No message text in the event. Client idle stop after 1.5s; heartbeat every 2s while still typing; remote indicator expires after 5s. Sender does not see their own indicator. Push notifications and email search are not implemented. 

26. Each message has an indicator whether it's been sent and delivered ✅

  

27. In case of failed message delivery, user receives visual feedback ✅

  

28. Each message has an indicator whether it's been read by recipient ✅

  

29. User can edit and delete their messages in the chat ✅

Phase 11: sender-only. Text messages can be edited (`editedAt`, re-encrypted ciphertext, same id). Text/image/video/audio can be soft-deleted (`deletedAt`; row and Media remain). History keeps deleted placeholders. `getChatMedia` rejects deleted messages. Realtime `messageEdited` / `messageDeleted` on the existing watch stream. Receipts and `Chat.lastMessageAt` are unchanged. Push notifications and email search are not implemented. 

30. Data persists after restarting the application ✅

  

31. Messages, media files, user profile information, and chat list contents are encrypted before they reach the database ✅

Phase 7 (application-layer AES-256-GCM, not E2EE):

- `Message.encryptedText` is ciphertext in PostgreSQL; APIs return plaintext
- `Profile.aboutMe` is ciphertext in PostgreSQL; APIs return plaintext
- `Chat.name` (group names) is ciphertext in PostgreSQL; APIs return plaintext
- `Media.encryptedData` is ciphertext in PostgreSQL; profile-image and chat-media APIs return original bytes
- Usernames/emails remain queryable for authentication and lookup
- Chat audio messages are WAV (`audio/wav`), max 10 MiB original bytes, stored as AES-256-GCM ciphertext in `Media.encryptedData`
- No plaintext message preview is stored on the chat list
- Chat/invitation listing still returns other rows if one group name cannot be decrypted; the unreadable name is omitted, not shown as plaintext


  

32. In case of errors or exceptions the messenger reloads whenever possible to the last stable state ✅

Failed loads and actions clear their loading state, keep the screen usable, and
show mapped feedback. Chat list / conversation / profile can retry. Returning
to the foreground refreshes chats, invitations, and the open conversation
without stacking identical requests.

  

33. Application code is properly organized and adheres to good practices

Verify logical organization of the `lib` folder files, check if code has consistent naming and formatting

  

34. All application tabs have a common theme and design. The interface is intuitive and user-friendly ✅

  

35. Project is easy to launch without installing full Flutter setup or other dependencies ✅

.apk file is provided and instructions are given to run it on Android, a lightweight emulator, and a browser-based emulator. Backend can be started with a single command with no manual setup required (except docker if used).

  

36. Application enables recording and sending audio messages in the chat. ✅

Phase 12: WAV (`audio/wav`, `.wav`), max 10 MiB original bytes. `record` 6.2.1 records on Android, iOS, and Web. `MessageEndpoint.sendAudio` validates RIFF/WAVE magic bytes, encrypts with AES-256-GCM, and stores ciphertext in `Media.encryptedData`. `Message.type = audio` and `Message.mediaId` only; realtime/history never include audio bytes. Playback uses `audioplayers` `BytesSource` after `getChatMedia`. Sender-only soft-delete (no edit). Microphone permission is requested when recording starts. Web recording requires a secure context (`https` or `localhost`).

  

37. Application features push notifications for new messages and chat invites ⚠️

Verify that user is able to mute notifications for any chat.

  

38. Application uses additional technologies and/or features beyond the core requirements ✅

- thumbnail generation for the video files ✅
- in-app unread message counts and pending invitation badges (not push) ✅
- Light / Dark Theme can be selected from the user profile ✅

Phase 17: Unread is a recipient `MessageReceipt` with `readAt == null` for a message the current user did not send. `ChatSummary.unreadCount` is computed in `listMine` from those receipts (deleted messages excluded). Own messages never count. Opening a conversation keeps using existing `markRead`; the chat-list badge is cleared for the active chat and does not increment for messages received while that conversation is open. Invitation badges are `listPendingMine.length`, updated on accept/decline/resume refresh, and on a new `ChatEventKind.invitation` posted to the receiver's existing user channel. Duplicate watch events are ignored by message/invitation id. Mute (`notificationsMuted`) still stores unread and still shows the in-app unread badge — mute is notification suppression, not unread suppression; no snackbar/banner is added. Archive is unchanged; a new message does not unarchive a chat. Chat list order remains `lastMessageAt`. Push / APNs / FCM stay on `feature/push-notifications`.

Phase 17.y: Existing `Profile.profileImageId` is included on chat/message/search/invitation DTOs as ids only. Flutter loads bytes through the existing `getProfileImage` endpoint (`mediaId` optional) and an in-memory `ProfileImageStore`. `ProfileAvatar` / `DefaultAvatar` are used on Home, chat rows, grouped messages, invitations, and contact search. Failed loads keep the placeholder and do not break the parent screen.

Phase 17.x: Realtime remains the primary live-update path. `ChatController` re-subscribes if the watch stream ends (same pattern as conversation). Opening the Invitations tab always calls `listPendingMine` via the existing in-flight `load` guard. Home polls `listMine` + `listPendingMine` about every 10s while that tab is visible and the app is resumed; the Invitations tab polls about every 5s. Polling stops on pause/hidden/dispose. A failed background poll keeps the current lists and does not show an error banner; manual Refresh / pull-to-refresh still surface recoverable errors. Conversation messages are not polled.