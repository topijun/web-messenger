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

import 'package:serverpod/serverpod.dart' as _i1;
import '../auth/email_idp_endpoint.dart' as _i2;
import '../auth/jwt_refresh_endpoint.dart' as _i3;
import '../chats/chat_endpoint.dart' as _i4;
import '../chats/chat_invitation_endpoint.dart' as _i5;
import '../devices/device_endpoint.dart' as _i6;
import '../greetings/greeting_endpoint.dart' as _i7;
import '../messages/message_endpoint.dart' as _i8;
import '../profiles/profile_endpoint.dart' as _i9;
import '../users/messenger_registration_endpoint.dart' as _i10;
import '../users/messenger_user_endpoint.dart' as _i11;
import 'package:messenger_server/src/generated/devices/device_platform.dart'
    as _i12;
import 'dart:typed_data' as _i13;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i14;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i15;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'emailIdp': _i2.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _i3.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'chat': _i4.ChatEndpoint()
        ..initialize(
          server,
          'chat',
          null,
        ),
      'chatInvitation': _i5.ChatInvitationEndpoint()
        ..initialize(
          server,
          'chatInvitation',
          null,
        ),
      'device': _i6.DeviceEndpoint()
        ..initialize(
          server,
          'device',
          null,
        ),
      'greeting': _i7.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
      'message': _i8.MessageEndpoint()
        ..initialize(
          server,
          'message',
          null,
        ),
      'profile': _i9.ProfileEndpoint()
        ..initialize(
          server,
          'profile',
          null,
        ),
      'messengerRegistration': _i10.MessengerRegistrationEndpoint()
        ..initialize(
          server,
          'messengerRegistration',
          null,
        ),
      'messengerUser': _i11.MessengerUserEndpoint()
        ..initialize(
          server,
          'messengerUser',
          null,
        ),
    };
    connectors['emailIdp'] = _i1.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint).login(
                session,
                email: params['email'],
                password: params['password'],
              ),
        ),
        'startRegistration': _i1.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _i1.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _i1.ParameterDescription(
              name: 'accountRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _i1.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _i1.ParameterDescription(
              name: 'registrationToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _i1.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _i1.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _i1.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _i1.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _i1.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _i1.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _i1.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _i1.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _i1.ParameterDescription(
              name: 'refreshToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['jwtRefresh'] as _i3.JwtRefreshEndpoint)
                  .refreshAccessToken(
                    session,
                    refreshToken: params['refreshToken'],
                  ),
        ),
      },
    );
    connectors['chat'] = _i1.EndpointConnector(
      name: 'chat',
      endpoint: endpoints['chat']!,
      methodConnectors: {
        'listMine': _i1.MethodConnector(
          name: 'listMine',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['chat'] as _i4.ChatEndpoint).listMine(session),
        ),
        'listMembers': _i1.MethodConnector(
          name: 'listMembers',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['chat'] as _i4.ChatEndpoint).listMembers(
                session,
                chatId: params['chatId'],
              ),
        ),
        'setArchived': _i1.MethodConnector(
          name: 'setArchived',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'archived': _i1.ParameterDescription(
              name: 'archived',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['chat'] as _i4.ChatEndpoint).setArchived(
                session,
                chatId: params['chatId'],
                archived: params['archived'],
              ),
        ),
        'setMuted': _i1.MethodConnector(
          name: 'setMuted',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'notificationsMuted': _i1.ParameterDescription(
              name: 'notificationsMuted',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['chat'] as _i4.ChatEndpoint).setMuted(
                session,
                chatId: params['chatId'],
                notificationsMuted: params['notificationsMuted'],
              ),
        ),
        'createGroup': _i1.MethodConnector(
          name: 'createGroup',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['chat'] as _i4.ChatEndpoint).createGroup(
                session,
                name: params['name'],
              ),
        ),
      },
    );
    connectors['chatInvitation'] = _i1.EndpointConnector(
      name: 'chatInvitation',
      endpoint: endpoints['chatInvitation']!,
      methodConnectors: {
        'inviteDirect': _i1.MethodConnector(
          name: 'inviteDirect',
          params: {
            'username': _i1.ParameterDescription(
              name: 'username',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['chatInvitation'] as _i5.ChatInvitationEndpoint)
                      .inviteDirect(
                        session,
                        username: params['username'],
                      ),
        ),
        'inviteToGroup': _i1.MethodConnector(
          name: 'inviteToGroup',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'username': _i1.ParameterDescription(
              name: 'username',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['chatInvitation'] as _i5.ChatInvitationEndpoint)
                      .inviteToGroup(
                        session,
                        chatId: params['chatId'],
                        username: params['username'],
                      ),
        ),
        'listPendingMine': _i1.MethodConnector(
          name: 'listPendingMine',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['chatInvitation'] as _i5.ChatInvitationEndpoint)
                      .listPendingMine(session),
        ),
        'accept': _i1.MethodConnector(
          name: 'accept',
          params: {
            'invitationId': _i1.ParameterDescription(
              name: 'invitationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['chatInvitation'] as _i5.ChatInvitationEndpoint)
                      .accept(
                        session,
                        invitationId: params['invitationId'],
                      ),
        ),
        'decline': _i1.MethodConnector(
          name: 'decline',
          params: {
            'invitationId': _i1.ParameterDescription(
              name: 'invitationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['chatInvitation'] as _i5.ChatInvitationEndpoint)
                      .decline(
                        session,
                        invitationId: params['invitationId'],
                      ),
        ),
      },
    );
    connectors['device'] = _i1.EndpointConnector(
      name: 'device',
      endpoint: endpoints['device']!,
      methodConnectors: {
        'register': _i1.MethodConnector(
          name: 'register',
          params: {
            'clientId': _i1.ParameterDescription(
              name: 'clientId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'platform': _i1.ParameterDescription(
              name: 'platform',
              type: _i1.getType<_i12.DevicePlatform>(),
              nullable: false,
            ),
            'pushToken': _i1.ParameterDescription(
              name: 'pushToken',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['device'] as _i6.DeviceEndpoint).register(
                session,
                clientId: params['clientId'],
                platform: params['platform'],
                pushToken: params['pushToken'],
              ),
        ),
        'touch': _i1.MethodConnector(
          name: 'touch',
          params: {
            'clientId': _i1.ParameterDescription(
              name: 'clientId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['device'] as _i6.DeviceEndpoint).touch(
                session,
                clientId: params['clientId'],
              ),
        ),
        'listMine': _i1.MethodConnector(
          name: 'listMine',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['device'] as _i6.DeviceEndpoint).listMine(session),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['greeting'] as _i7.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
    connectors['message'] = _i1.EndpointConnector(
      name: 'message',
      endpoint: endpoints['message']!,
      methodConnectors: {
        'sendText': _i1.MethodConnector(
          name: 'sendText',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'encryptedText': _i1.ParameterDescription(
              name: 'encryptedText',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['message'] as _i8.MessageEndpoint).sendText(
                session,
                chatId: params['chatId'],
                encryptedText: params['encryptedText'],
              ),
        ),
        'sendMedia': _i1.MethodConnector(
          name: 'sendMedia',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'bytes': _i1.ParameterDescription(
              name: 'bytes',
              type: _i1.getType<_i13.ByteData>(),
              nullable: false,
            ),
            'thumbnailBytes': _i1.ParameterDescription(
              name: 'thumbnailBytes',
              type: _i1.getType<_i13.ByteData?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['message'] as _i8.MessageEndpoint).sendMedia(
                    session,
                    chatId: params['chatId'],
                    bytes: params['bytes'],
                    thumbnailBytes: params['thumbnailBytes'],
                  ),
        ),
        'sendAudio': _i1.MethodConnector(
          name: 'sendAudio',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'bytes': _i1.ParameterDescription(
              name: 'bytes',
              type: _i1.getType<_i13.ByteData>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['message'] as _i8.MessageEndpoint).sendAudio(
                    session,
                    chatId: params['chatId'],
                    bytes: params['bytes'],
                  ),
        ),
        'getChatMedia': _i1.MethodConnector(
          name: 'getChatMedia',
          params: {
            'mediaId': _i1.ParameterDescription(
              name: 'mediaId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['message'] as _i8.MessageEndpoint).getChatMedia(
                    session,
                    mediaId: params['mediaId'],
                  ),
        ),
        'searchText': _i1.MethodConnector(
          name: 'searchText',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'query': _i1.ParameterDescription(
              name: 'query',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['message'] as _i8.MessageEndpoint).searchText(
                    session,
                    chatId: params['chatId'],
                    query: params['query'],
                  ),
        ),
        'listHistory': _i1.MethodConnector(
          name: 'listHistory',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'beforeCreatedAt': _i1.ParameterDescription(
              name: 'beforeCreatedAt',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
            'beforeId': _i1.ParameterDescription(
              name: 'beforeId',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['message'] as _i8.MessageEndpoint).listHistory(
                    session,
                    chatId: params['chatId'],
                    beforeCreatedAt: params['beforeCreatedAt'],
                    beforeId: params['beforeId'],
                    limit: params['limit'],
                  ),
        ),
        'markDelivered': _i1.MethodConnector(
          name: 'markDelivered',
          params: {
            'messageIds': _i1.ParameterDescription(
              name: 'messageIds',
              type: _i1.getType<List<int>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['message'] as _i8.MessageEndpoint).markDelivered(
                    session,
                    messageIds: params['messageIds'],
                  ),
        ),
        'markRead': _i1.MethodConnector(
          name: 'markRead',
          params: {
            'messageIds': _i1.ParameterDescription(
              name: 'messageIds',
              type: _i1.getType<List<int>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['message'] as _i8.MessageEndpoint).markRead(
                session,
                messageIds: params['messageIds'],
              ),
        ),
        'setTyping': _i1.MethodConnector(
          name: 'setTyping',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'isTyping': _i1.ParameterDescription(
              name: 'isTyping',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['message'] as _i8.MessageEndpoint).setTyping(
                    session,
                    chatId: params['chatId'],
                    isTyping: params['isTyping'],
                  ),
        ),
        'editText': _i1.MethodConnector(
          name: 'editText',
          params: {
            'messageId': _i1.ParameterDescription(
              name: 'messageId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'encryptedText': _i1.ParameterDescription(
              name: 'encryptedText',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['message'] as _i8.MessageEndpoint).editText(
                session,
                messageId: params['messageId'],
                encryptedText: params['encryptedText'],
              ),
        ),
        'deleteMessage': _i1.MethodConnector(
          name: 'deleteMessage',
          params: {
            'messageId': _i1.ParameterDescription(
              name: 'messageId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['message'] as _i8.MessageEndpoint).deleteMessage(
                    session,
                    messageId: params['messageId'],
                  ),
        ),
        'watch': _i1.MethodStreamConnector(
          name: 'watch',
          params: {},
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['message'] as _i8.MessageEndpoint).watch(session),
        ),
      },
    );
    connectors['profile'] = _i1.EndpointConnector(
      name: 'profile',
      endpoint: endpoints['profile']!,
      methodConnectors: {
        'getMine': _i1.MethodConnector(
          name: 'getMine',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['profile'] as _i9.ProfileEndpoint).getMine(
                session,
              ),
        ),
        'updateMine': _i1.MethodConnector(
          name: 'updateMine',
          params: {
            'aboutMe': _i1.ParameterDescription(
              name: 'aboutMe',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['profile'] as _i9.ProfileEndpoint).updateMine(
                    session,
                    aboutMe: params['aboutMe'],
                  ),
        ),
        'uploadProfileImage': _i1.MethodConnector(
          name: 'uploadProfileImage',
          params: {
            'bytes': _i1.ParameterDescription(
              name: 'bytes',
              type: _i1.getType<_i13.ByteData>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['profile'] as _i9.ProfileEndpoint)
                  .uploadProfileImage(
                    session,
                    bytes: params['bytes'],
                  ),
        ),
        'getProfileImage': _i1.MethodConnector(
          name: 'getProfileImage',
          params: {
            'mediaId': _i1.ParameterDescription(
              name: 'mediaId',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['profile'] as _i9.ProfileEndpoint).getProfileImage(
                    session,
                    mediaId: params['mediaId'],
                  ),
        ),
      },
    );
    connectors['messengerRegistration'] = _i1.EndpointConnector(
      name: 'messengerRegistration',
      endpoint: endpoints['messengerRegistration']!,
      methodConnectors: {
        'start': _i1.MethodConnector(
          name: 'start',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'username': _i1.ParameterDescription(
              name: 'username',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['messengerRegistration']
                          as _i10.MessengerRegistrationEndpoint)
                      .start(
                        session,
                        email: params['email'],
                        username: params['username'],
                      ),
        ),
        'verify': _i1.MethodConnector(
          name: 'verify',
          params: {
            'accountRequestId': _i1.ParameterDescription(
              name: 'accountRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['messengerRegistration']
                          as _i10.MessengerRegistrationEndpoint)
                      .verify(
                        session,
                        accountRequestId: params['accountRequestId'],
                        verificationCode: params['verificationCode'],
                      ),
        ),
        'finish': _i1.MethodConnector(
          name: 'finish',
          params: {
            'registrationToken': _i1.ParameterDescription(
              name: 'registrationToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['messengerRegistration']
                          as _i10.MessengerRegistrationEndpoint)
                      .finish(
                        session,
                        registrationToken: params['registrationToken'],
                        password: params['password'],
                      ),
        ),
      },
    );
    connectors['messengerUser'] = _i1.EndpointConnector(
      name: 'messengerUser',
      endpoint: endpoints['messengerUser']!,
      methodConnectors: {
        'get': _i1.MethodConnector(
          name: 'get',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['messengerUser'] as _i11.MessengerUserEndpoint)
                      .get(session),
        ),
        'lookupByUsername': _i1.MethodConnector(
          name: 'lookupByUsername',
          params: {
            'username': _i1.ParameterDescription(
              name: 'username',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['messengerUser'] as _i11.MessengerUserEndpoint)
                      .lookupByUsername(
                        session,
                        username: params['username'],
                      ),
        ),
        'searchContact': _i1.MethodConnector(
          name: 'searchContact',
          params: {
            'query': _i1.ParameterDescription(
              name: 'query',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['messengerUser'] as _i11.MessengerUserEndpoint)
                      .searchContact(
                        session,
                        query: params['query'],
                      ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i14.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i15.Endpoints()
      ..initializeEndpoints(server);
  }
}
