

# Requirements — Web Messenger (Mobile App Development)

1. Repository contains complete source code and configuration files

2. Documentation (README) includes all required sections
   Check presence of:
- Project overview
- Complete setup instructions
- Usage guide

3. Application is deployed successfully on chosen hosting platform

4. User can create an account with email, username and password

5. Registration is not allowed if email or username is already in use
   Verify that user receives proper visual feedback

6. User's email is verified before creating an account

7. User needs to provide email and password to log in

8. User can reset their account's password

9. User has a profile page within an application
   Verify that the profile page features at least a username, a profile picture, and About Me sections

10. User has a default profile picture upon first log in to the application

11. Application supports uploading a profile picture at least in JPEG and PNG formats

12. User can edit any data in their profile

13. User can search for contacts by username or by email

14. User can send individual chat invitations to other users

15. User can send group chat invitations to other users

16. User can accept or decline the chat invitation

17. Application has a pending invitation section

18. Application has a chat list sorted by the time of the last message received or sent

19. Users are able to send text messages to each other

20. Users are able to send images to each other

21. Users are able to send videos to each other

22. Chat has typing indicators showing whether either user is typing a message in real time

23. Each message has an indicator whether it's been sent and delivered

24. In case of failed message delivery, user receives visual feedback

25. Each message has an indicator whether it's been read by recipient

26. User can edit and delete their messages in the chat

27. Application features text message search functionality in individual and group chats

28. Search highlights matching messages, if they are found

29. Users are able to navigate through search results within the chat

30. Data persists after restarting the application

31. Messages, media files, user profile information, and chat list contents are encrypted before they reach the database

32. In case of errors or exceptions the messenger reloads whenever possible to the last stable state
   Verify that user receives visual feedback about the error/exception

33. Messages are synchronized between Web and Mobile versions of the messenger

34. Messages between platforms are instantaneous
   Text messages reach 'delivered' status in under 2 seconds

35. Platform supports independent sessions
   Same user can be logged in from both mobile- and web messengers

36. Platform supports selective logout
   Logging out from one device does not terminate other active sessions

37. Mobile Messenger codebase and UI are successfully adapted for the web

38. Application code is properly organized and adheres to good practices
   Verify logical organization of the `lib` folder files, check if code has consistent naming and formatting

39. All application tabs have a common theme and design. The interface is intuitive and user-friendly

40. Application allows users to create public or anonymous polls in the group chats
   Verify that votes can be changed or retracted

41. Application allows user to open at least 2 chats on the same web page

42. Application uses additional technologies and/or features beyond the core requirements

