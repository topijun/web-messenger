/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i1;
import 'package:serverpod_client/serverpod_client.dart' as _i2;
import 'dart:async' as _i3;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i4;
import 'package:messenger_client/src/protocol/chats/chat_summary.dart' as _i5;
import 'package:messenger_client/src/protocol/chats/chat_member.dart' as _i6;
import 'package:messenger_client/src/protocol/chats/chat_participant.dart'
    as _i7;
import 'package:messenger_client/src/protocol/chats/chat_invitation_view.dart'
    as _i8;
import 'package:messenger_client/src/protocol/devices/device.dart' as _i9;
import 'package:messenger_client/src/protocol/devices/device_platform.dart'
    as _i10;
import 'package:messenger_client/src/protocol/greetings/greeting.dart' as _i11;
import 'package:messenger_client/src/protocol/messages/message_view.dart'
    as _i12;
import 'dart:typed_data' as _i13;
import 'package:messenger_client/src/protocol/media/chat_media.dart' as _i14;
import 'package:messenger_client/src/protocol/messages/message_history_page.dart'
    as _i15;
import 'package:messenger_client/src/protocol/messages/message_receipt.dart'
    as _i16;
import 'package:messenger_client/src/protocol/messages/chat_event.dart' as _i17;
import 'package:messenger_client/src/protocol/profiles/profile.dart' as _i18;
import 'package:messenger_client/src/protocol/media/profile_image.dart' as _i19;
import 'package:messenger_client/src/protocol/users/messenger_user.dart'
    as _i20;
import 'package:messenger_client/src/protocol/users/contact_search_result.dart'
    as _i21;
import 'protocol.dart' as _i22;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _i1.EndpointEmailIdpBase {
  EndpointEmailIdp(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<_i4.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _i3.Future<_i2.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _i3.Future<String> verifyRegistrationCode({
    required _i2.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _i3.Future<_i4.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _i3.Future<_i2.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _i3.Future<String> verifyPasswordResetCode({
    required _i2.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _i3.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _i4.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _i3.Future<_i4.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'jwtRefresh',
    'refreshAccessToken',
    {'refreshToken': refreshToken},
    authenticated: false,
  );
}

/// Authenticated chat list, membership, and group creation.
/// {@category Endpoint}
class EndpointChat extends _i2.EndpointRef {
  EndpointChat(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'chat';

  /// Lists chats the signed-in user belongs to.
  _i3.Future<List<_i5.ChatSummary>> listMine() =>
      caller.callServerEndpoint<List<_i5.ChatSummary>>(
        'chat',
        'listMine',
        {},
      );

  /// Lists members of a chat the signed-in user belongs to.
  _i3.Future<List<_i6.ChatMember>> listMembers({required int chatId}) =>
      caller.callServerEndpoint<List<_i6.ChatMember>>(
        'chat',
        'listMembers',
        {'chatId': chatId},
      );

  /// Archives or unarchives a chat for the signed-in user.
  _i3.Future<_i7.ChatParticipant> setArchived({
    required int chatId,
    required bool archived,
  }) => caller.callServerEndpoint<_i7.ChatParticipant>(
    'chat',
    'setArchived',
    {
      'chatId': chatId,
      'archived': archived,
    },
  );

  /// Mutes or unmutes a chat for the signed-in user.
  _i3.Future<_i7.ChatParticipant> setMuted({
    required int chatId,
    required bool notificationsMuted,
  }) => caller.callServerEndpoint<_i7.ChatParticipant>(
    'chat',
    'setMuted',
    {
      'chatId': chatId,
      'notificationsMuted': notificationsMuted,
    },
  );

  /// Creates a group chat with the signed-in user as admin.
  _i3.Future<_i5.ChatSummary> createGroup({required String name}) =>
      caller.callServerEndpoint<_i5.ChatSummary>(
        'chat',
        'createGroup',
        {'name': name},
      );
}

/// Authenticated chat invitations for the signed-in user.
/// {@category Endpoint}
class EndpointChatInvitation extends _i2.EndpointRef {
  EndpointChatInvitation(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'chatInvitation';

  /// Invites [username] to a new direct chat.
  _i3.Future<_i8.ChatInvitationView> inviteDirect({required String username}) =>
      caller.callServerEndpoint<_i8.ChatInvitationView>(
        'chatInvitation',
        'inviteDirect',
        {'username': username},
      );

  /// Invites [username] to an existing group. Caller must be an admin.
  _i3.Future<_i8.ChatInvitationView> inviteToGroup({
    required int chatId,
    required String username,
  }) => caller.callServerEndpoint<_i8.ChatInvitationView>(
    'chatInvitation',
    'inviteToGroup',
    {
      'chatId': chatId,
      'username': username,
    },
  );

  /// Pending invitations addressed to the signed-in user.
  _i3.Future<List<_i8.ChatInvitationView>> listPendingMine() =>
      caller.callServerEndpoint<List<_i8.ChatInvitationView>>(
        'chatInvitation',
        'listPendingMine',
        {},
      );

  /// Accepts an invitation addressed to the signed-in user.
  _i3.Future<_i5.ChatSummary> accept({required int invitationId}) =>
      caller.callServerEndpoint<_i5.ChatSummary>(
        'chatInvitation',
        'accept',
        {'invitationId': invitationId},
      );

  /// Declines an invitation addressed to the signed-in user.
  _i3.Future<_i8.ChatInvitationView> decline({required int invitationId}) =>
      caller.callServerEndpoint<_i8.ChatInvitationView>(
        'chatInvitation',
        'decline',
        {'invitationId': invitationId},
      );
}

/// Authenticated access to the current user's [Device] installations.
/// {@category Endpoint}
class EndpointDevice extends _i2.EndpointRef {
  EndpointDevice(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'device';

  /// Registers or updates this client installation.
  _i3.Future<_i9.Device> register({
    required _i2.UuidValue clientId,
    required _i10.DevicePlatform platform,
    String? pushToken,
  }) => caller.callServerEndpoint<_i9.Device>(
    'device',
    'register',
    {
      'clientId': clientId,
      'platform': platform,
      'pushToken': pushToken,
    },
  );

  /// Updates last-seen for this client installation.
  _i3.Future<_i9.Device> touch({required _i2.UuidValue clientId}) =>
      caller.callServerEndpoint<_i9.Device>(
        'device',
        'touch',
        {'clientId': clientId},
      );

  /// Lists installations belonging to the signed-in user.
  _i3.Future<List<_i9.Device>> listMine() =>
      caller.callServerEndpoint<List<_i9.Device>>(
        'device',
        'listMine',
        {},
      );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i2.EndpointRef {
  EndpointGreeting(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i3.Future<_i11.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i11.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

/// Authenticated text/image/video/audio messages, history, receipts, and realtime.
/// {@category Endpoint}
class EndpointMessage extends _i2.EndpointRef {
  EndpointMessage(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'message';

  /// Sends a text message in a chat the caller belongs to.
  ///
  /// [encryptedText] is plaintext from the client. The server encrypts it
  /// before PostgreSQL persistence.
  _i3.Future<_i12.MessageView> sendText({
    required int chatId,
    required String encryptedText,
  }) => caller.callServerEndpoint<_i12.MessageView>(
    'message',
    'sendText',
    {
      'chatId': chatId,
      'encryptedText': encryptedText,
    },
  );

  /// Sends a JPEG, PNG, MP4, or WebM message in a chat the caller belongs to.
  ///
  /// [bytes] are plaintext. The server encrypts them before persistence.
  /// The returned view includes [Message.mediaId]; media bytes are retrieved
  /// separately with [getChatMedia].
  _i3.Future<_i12.MessageView> sendMedia({
    required int chatId,
    required _i13.ByteData bytes,
    _i13.ByteData? thumbnailBytes,
  }) => caller.callServerEndpoint<_i12.MessageView>(
    'message',
    'sendMedia',
    {
      'chatId': chatId,
      'bytes': bytes,
      'thumbnailBytes': thumbnailBytes,
    },
  );

  /// Sends a WAV audio message in a chat the caller belongs to.
  ///
  /// [bytes] are plaintext. The server encrypts them before persistence.
  /// The returned view includes [Message.mediaId]; audio bytes are retrieved
  /// separately with [getChatMedia].
  _i3.Future<_i12.MessageView> sendAudio({
    required int chatId,
    required _i13.ByteData bytes,
  }) => caller.callServerEndpoint<_i12.MessageView>(
    'message',
    'sendAudio',
    {
      'chatId': chatId,
      'bytes': bytes,
    },
  );

  /// Decrypts chat media for a member of the chat that owns the message.
  _i3.Future<_i14.ChatMedia> getChatMedia({required int mediaId}) =>
      caller.callServerEndpoint<_i14.ChatMedia>(
        'message',
        'getChatMedia',
        {'mediaId': mediaId},
      );

  /// Case-insensitive text search in a chat the caller belongs to.
  ///
  /// [query] is plaintext. The server decrypts stored message text and
  /// matches it in memory. PostgreSQL is not asked to search ciphertext.
  _i3.Future<List<_i12.MessageView>> searchText({
    required int chatId,
    required String query,
  }) => caller.callServerEndpoint<List<_i12.MessageView>>(
    'message',
    'searchText',
    {
      'chatId': chatId,
      'query': query,
    },
  );

  /// Newest-first history for a chat the caller belongs to.
  _i3.Future<_i15.MessageHistoryPage> listHistory({
    required int chatId,
    DateTime? beforeCreatedAt,
    int? beforeId,
    int? limit,
  }) => caller.callServerEndpoint<_i15.MessageHistoryPage>(
    'message',
    'listHistory',
    {
      'chatId': chatId,
      'beforeCreatedAt': beforeCreatedAt,
      'beforeId': beforeId,
      'limit': limit,
    },
  );

  /// Creates a poll message in a group chat the caller belongs to.
  ///
  /// [question] and [options] are plaintext. The server encrypts them.
  _i3.Future<_i12.MessageView> createPoll({
    required int chatId,
    required String question,
    required List<String> options,
    required bool anonymous,
  }) => caller.callServerEndpoint<_i12.MessageView>(
    'message',
    'createPoll',
    {
      'chatId': chatId,
      'question': question,
      'options': options,
      'anonymous': anonymous,
    },
  );

  /// Selects [optionId] for the caller.
  ///
  /// Choosing the current option retracts the vote. Choosing a different
  /// option replaces it.
  _i3.Future<_i12.MessageView> vote({
    required int pollId,
    required int optionId,
  }) => caller.callServerEndpoint<_i12.MessageView>(
    'message',
    'vote',
    {
      'pollId': pollId,
      'optionId': optionId,
    },
  );

  /// Marks messages as delivered for the authenticated recipient.
  _i3.Future<List<_i16.MessageReceipt>> markDelivered({
    required List<int> messageIds,
  }) => caller.callServerEndpoint<List<_i16.MessageReceipt>>(
    'message',
    'markDelivered',
    {'messageIds': messageIds},
  );

  /// Marks messages as read for the authenticated recipient.
  _i3.Future<List<_i16.MessageReceipt>> markRead({
    required List<int> messageIds,
  }) => caller.callServerEndpoint<List<_i16.MessageReceipt>>(
    'message',
    'markRead',
    {'messageIds': messageIds},
  );

  /// Serverpod streaming method for new messages, receipts, and typing.
  ///
  /// Uses [MessageCentral], not a custom WebSocket. The database remains
  /// authoritative if the client misses message events. Typing is transient.
  _i3.Stream<_i17.ChatEvent> watch() => caller
      .callStreamingServerEndpoint<_i3.Stream<_i17.ChatEvent>, _i17.ChatEvent>(
        'message',
        'watch',
        {},
        {},
      );

  /// Emits a transient typing start/stop event to other members of [chatId].
  ///
  /// Does not persist anything. Draft text is never included.
  _i3.Future<void> setTyping({
    required int chatId,
    required bool isTyping,
  }) => caller.callServerEndpoint<void>(
    'message',
    'setTyping',
    {
      'chatId': chatId,
      'isTyping': isTyping,
    },
  );

  /// Replaces the body of the caller's own text message.
  ///
  /// [encryptedText] is plaintext from the client. The server encrypts it
  /// before PostgreSQL update. Receipts and [Chat.lastMessageAt] are unchanged.
  _i3.Future<_i12.MessageView> editText({
    required int messageId,
    required String encryptedText,
  }) => caller.callServerEndpoint<_i12.MessageView>(
    'message',
    'editText',
    {
      'messageId': messageId,
      'encryptedText': encryptedText,
    },
  );

  /// Soft-deletes the caller's own message. The row is kept.
  _i3.Future<_i12.MessageView> deleteMessage({required int messageId}) =>
      caller.callServerEndpoint<_i12.MessageView>(
        'message',
        'deleteMessage',
        {'messageId': messageId},
      );
}

/// Authenticated access to the current user's [Profile].
/// {@category Endpoint}
class EndpointProfile extends _i2.EndpointRef {
  EndpointProfile(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'profile';

  /// Returns the signed-in user's profile, creating one if missing.
  _i3.Future<_i18.Profile> getMine() => caller.callServerEndpoint<_i18.Profile>(
    'profile',
    'getMine',
    {},
  );

  /// Updates the signed-in user's about-me text.
  _i3.Future<_i18.Profile> updateMine({required String aboutMe}) =>
      caller.callServerEndpoint<_i18.Profile>(
        'profile',
        'updateMine',
        {'aboutMe': aboutMe},
      );

  /// Uploads a JPEG or PNG (max 5 MB) as the signed-in user's profile picture.
  ///
  /// The server validates magic bytes, encrypts with AES-256-GCM, and stores
  /// ciphertext in PostgreSQL. Replaces any previous picture.
  _i3.Future<_i19.ProfileImage> uploadProfileImage({
    required _i13.ByteData bytes,
  }) => caller.callServerEndpoint<_i19.ProfileImage>(
    'profile',
    'uploadProfileImage',
    {'bytes': bytes},
  );

  /// Returns a decrypted profile picture.
  ///
  /// Omitting [mediaId] returns the current user's picture. Passing [mediaId]
  /// returns that image when it is a stored profile picture.
  _i3.Future<_i19.ProfileImage?> getProfileImage({int? mediaId}) =>
      caller.callServerEndpoint<_i19.ProfileImage?>(
        'profile',
        'getProfileImage',
        {'mediaId': mediaId},
      );
}

/// Public Messenger registration API.
///
/// Flutter should use this endpoint instead of orchestrating Email IDP and
/// MessengerUser creation separately.
/// {@category Endpoint}
class EndpointMessengerRegistration extends _i2.EndpointRef {
  EndpointMessengerRegistration(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'messengerRegistration';

  /// Starts registration for [email] and [username].
  _i3.Future<_i2.UuidValue> start({
    required String email,
    required String username,
  }) => caller.callServerEndpoint<_i2.UuidValue>(
    'messengerRegistration',
    'start',
    {
      'email': email,
      'username': username,
    },
  );

  /// Verifies the email code and returns a registration token.
  _i3.Future<String> verify({
    required _i2.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'messengerRegistration',
    'verify',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes registration and returns an authenticated session.
  _i3.Future<_i4.AuthSuccess> finish({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'messengerRegistration',
    'finish',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );
}

/// Authenticated access to the current user's [MessengerUser].
/// {@category Endpoint}
class EndpointMessengerUser extends _i2.EndpointRef {
  EndpointMessengerUser(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'messengerUser';

  /// Returns the [MessengerUser] for the signed-in [AuthUser], if one exists.
  _i3.Future<_i20.MessengerUser?> get() =>
      caller.callServerEndpoint<_i20.MessengerUser?>(
        'messengerUser',
        'get',
        {},
      );

  /// Looks up a Messenger user by username, ignoring case.
  ///
  /// Returns null when no matching account exists.
  _i3.Future<_i20.MessengerUser?> lookupByUsername({
    required String username,
  }) => caller.callServerEndpoint<_i20.MessengerUser?>(
    'messengerUser',
    'lookupByUsername',
    {'username': username},
  );

  /// Finds a contact by exact username or email for the invitation flow.
  ///
  /// The server treats a query containing `@` as email and otherwise as
  /// username. Returns null when no registered user matches.
  _i3.Future<_i21.ContactSearchResult?> searchContact({
    required String query,
  }) => caller.callServerEndpoint<_i21.ContactSearchResult?>(
    'messengerUser',
    'searchContact',
    {'query': query},
  );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i1.Caller(client);
    serverpod_auth_core = _i4.Caller(client);
  }

  late final _i1.Caller serverpod_auth_idp;

  late final _i4.Caller serverpod_auth_core;
}

class Client extends _i2.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i2.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i2.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i22.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    chat = EndpointChat(this);
    chatInvitation = EndpointChatInvitation(this);
    device = EndpointDevice(this);
    greeting = EndpointGreeting(this);
    message = EndpointMessage(this);
    profile = EndpointProfile(this);
    messengerRegistration = EndpointMessengerRegistration(this);
    messengerUser = EndpointMessengerUser(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointChat chat;

  late final EndpointChatInvitation chatInvitation;

  late final EndpointDevice device;

  late final EndpointGreeting greeting;

  late final EndpointMessage message;

  late final EndpointProfile profile;

  late final EndpointMessengerRegistration messengerRegistration;

  late final EndpointMessengerUser messengerUser;

  late final Modules modules;

  @override
  Map<String, _i2.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'chat': chat,
    'chatInvitation': chatInvitation,
    'device': device,
    'greeting': greeting,
    'message': message,
    'profile': profile,
    'messengerRegistration': messengerRegistration,
    'messengerUser': messengerUser,
  };

  @override
  Map<String, _i2.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
