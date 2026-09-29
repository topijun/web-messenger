
Avatar not present on direct chat nav bar

---
## Refresh  and Notifications - Fixed ✅ 

When testing with emulators
- it seems that the app does not refresh without clicking the manual refresh button
	- this is needed to see new invitations and chats
- Notifications for invitations and messages missing

---

## New Video Thumbnail

There is no thumbnail for is unavailable if the conversation is open
- Fixed ✅ 

---
## Manual test — 2026-09-18

[PASS] Alice registration
[PASS] Bob registration
[PASS] Login/logout
[PASS] Session persistence
[PASS] Profile About Me
[PASS] Direct invitation
[FAIL] Direct accept
[FAIL] Direct decline
[PASS] Duplicate invitation
[FAIL] Existing direct chat protection
[PASS] Group creation
[PASS] Group invitation
[FAIL] Group accept
[FAIL] Non-admin cannot invite
[PASS] Archive
[PASS] Unarchive
[PASS] Mute
[PASS] Unmute

Issues:
* Create user / Log in / Send invitation / User lookup ok
* User name not showing on home screen > Fixed ✅ 
- Invitations list remains empty > Fixed ✅ 
- Duplicate invitation > ui responds with "already pending" message
- Create Group Chat / Admin user / Invite user  / Archive ok
- 

--- 