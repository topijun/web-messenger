
- Phases 0-7 finished already
- This is an outline for the remaining phases
- Some of the steps might be combined if it seems appropriate
- The numbers starting with *#* refer to test cases

```
PHASE 0–7  ✅ Foundation → Encryption

PHASE 8    ✅ Media foundation + profile pictures
           → #14, #15, #31

PHASE 9    ✅ Image + video messages
           → #23, #24

PHASE 10   ✅ Typing indicators
           → #25

PHASE 11   ✅ Message edit/delete
           → #29

PHASE 12   ✅ Audio messages
           → #36

PHASE 13   ⚠️ Push notifications
           → #37
           → Implemented but not merged to main
           → not able to use/test on iphone

PHASE 14   ✅ Search completion + email search 
           → #16
           
PHASE 15   ✅ Reset password
		   → #10
		   → Official Email IDP start/verify/finish

PHASE 16   ✅ Verification email
		   → #8
		   → Gmail SMTP via Email IDP callbacks (registration + password reset)
		

PHASE 16   ✅ Error UX
		   → #32
		   → Recoverable loading/error states + app-resume refresh 

PHASE 17   ✅ In-app notifications
		   → #38
		   → Unread chat-list badges + pending invitation badge
		   → Derived from MessageReceipt.readAt and listPendingMine
		   → Realtime via the existing MessageCentral user channel
		   → Mute still stores unread; archive is unchanged / no auto-unarchive

PHASE 17.y ✅ Profile pictures across chats, messages, and search
		   → Reused Profile.profileImageId + getProfileImage(mediaId)
		   → ProfileAvatar + in-memory cache
		   → Home, chat rows, messages, invitations, contact search

PHASE 17.x ✅ State refresh and realtime reliability
		   → Invitation events still use ChatEventKind.invitation
		   → Invitations tab refetches listPendingMine on open
		   → Lifecycle polling: Home ~10s, Invitations ~5s (safety net only)
		   → No message polling; conversation realtime + resume stay primary

PHASE 18   UI polish / error UX / final consistency
           → #3, #32, #34
           
PHASE 19   Empty database and create test users and make a readme entry          

PHASE 19   Deployment + APK + README/final packaging
           → #35

FINAL      Architecture/code review
           → #33
           → #38
           → full test matrix
```

