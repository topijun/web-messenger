
# Mobile Messenger 📲

  

A Flutter messaging app to communicate with anyone.

  

## The situation 👀

  

Mobile messengers are essential part of the daily life, allowing to easily stay in touch with family, friends, and colleagues. However, despite messenger apps growing popularity, only a handful of them dominate the market, often lacking the flexibility to meet everyone's specific needs or desired features.

  

So you decide to create a Flutter messenger app with functionality and customization you've always wanted.

  

## Functional requirements 📌

  

You are to create the messenger with the [Flutter](https://flutter.dev) framework. When finished, you should be able to demonstrate that the project works on iOS or Android. You can use either an emulator or a physical device to show the application functionality.

  

This is a full-stack project, so you will need to implement both backend and frontend, as well as data persistence.

  

The application has to support the following features:

  

### Registration & Authentication

  

User has to submit their email, password, and username to create an account in the application. To log in, only the email and password are required.

  

If the user's chosen username or email is already in use, registration should not be allowed. The user has to get **visual feedback** if they attempt to create an account with an existing email or username.

  

Application should check the password strength. Password should contain:

- at least 8 characters

- at least 1 lowercase letter

- at least 1 uppercase letter

- at least 1 digit

- at least 1 special character

  

If the password does not pass the strength check, registration should not be allowed. User has to get corresponding **visual feedback**.

  

Application should feature email verification.

  

User must be able to reset their password via Email-based Password Recovery.

  

Application should ensure that a user remains logged in even after closing and reopening the messenger, unless they explicitly log out or their session expires.

  

### User profile

  

User has to have a profile page in the application, which at least consists of a profile picture, username, and _About me_ section. You are free to add other profile sections.

  

Upon the first log into the application, profile picture features some default image and _About me_ section is empty.

  

Application should support at least both JPEG and PNG formats for profile picture upload. Profile picture size limit is 5MB.

  

User should be able to edit any data in the profile.

  

### Search

  

User must be able to search for other users by their current username or by email.

  

### Invite

  

User should be able to send and receive chat invitations. Invitation can be accepted or declined.

  

There is no need to use invites if the designated person is already in the user's chat list.

  

Application should have a list of pending invitations.

  

### Chat list

  

Application must have a chat list sorted by the time of the last message received or sent.

  

Tapping on a list item navigates to the specific chat.

  

User should be able to archive a specific chat and unarchive it at any time.

  

### Messaging

  

Users must be able to send **text messages, images and videos** to each other. Size limit for image and video files is 20MB after compression.

  

All messages should have visual indicators that show whether they have been sent, delivered and read by the recipient, with corresponding visual feedback if delivery fails.

  

Users should be able to edit and delete their own messages in the chat.

  

Chats need to have typing indicators - visual cues that inform a user when their chat contact is in the process of composing a message.

  

### Data encryption

  

Application should encrypt user's sensitive data before it is inserted or updated in the database. Text messages, media files, user profile data, and list of contacts/chats must be encrypted using strong encryption algorithms of your choice.

  

### Error handling

  

In case of any common errors/failures/interruptions the messenger should give visual feedback about the situation to the user and return to the last stable application state.

  

### Expected outcome 🎯

  

The finished project should have the following:

  

- User can create an account in the application with email, password and username.

- Application features a profile page.

- Application has an organized chat list.

- User can send and receive chat invites to/from other users.

- User is able to edit and delete their messages.

- Sensitive data is encrypted.

  

## Extra requirements 📚

  

### Reviewer-Friendly Setup

  

To simplify the review and testing process, include ready-to-install `.apk` file so your project can be run without requiring a full Flutter or Android Studio setup. Also the backend should start with a single command, no manual installation of language runtimes, libraries, or additional dependencies should be required (e.g. docker or simple script).

The reviewer should be able to interact with the app using the following quick methods:

- Install directly on an Android device

- Use a lightweight emulator (e.g. NoxPlayer, BlueStacks)

- Browser-based online emulator (e.g. [appetize](https://appetize.io))

A short Reviewer Guide section must be provided in the README explaining how to use each option above to open and interact with the app. If the `.apk` file exceeds Git hosting limits (e.g., >20–50 MB), it should be provided via external storage (e.g. Google Drive, Dropbox, or a GitHub Release).

  

### Audio chat

  

Enable users to record messages with the device microphone and send them in the chat. Users should be able to play received audio messages in the chat.

  

### Push notifications

  

Implement push notifications for chat messages and user invites. User should be able to mute notifications for any chat.

  

## Bonus functionality 🎁

  

You're welcome to implement other features as you see fit. But anything you implement should not change the default functional behavior of your project.

  

You may use any additional tools, command line arguments, or separate builds to switch your bonus functionality on.

  

## Useful links 🔗

  

- [Flutter Docs](https://flutter.dev/)

- [Dart Docs](https://dart.dev/)

- [Flutter widget catalog](https://docs.flutter.dev/ui/widgets)

- [Backend Development With Serverpod](https://docs.serverpod.dev/0.9.20/tutorials)

- [Password Strength Checker](https://pub.dev/packages/password_strength_checker)

- [Flutter Email Verification](https://pub.dev/packages/email_otp)

- [Cryptography in Flutter](https://medium.com/@rishad2002/cryptography-in-flutter-6b5cbf0c2a75)

  

## What you'll learn 🧠

  

- Building messenger applications with Flutter

- Working with backend routes and services

- Persisting state and data

- Secure storage

- Real-time indicators

  

## Deliverables and Review Requirements 📁

  

- All source code and configuration files

- A README file with:

- Project overview

- Setup and installation instructions

- Usage guide

- Any additional features or bonus functionality implemented

  

During the review, be prepared to:

  

- Demonstrate the application on iOS or Android emulator/physical device

- Explain your code and design choices

- Discuss any challenges you faced and how you overcame them