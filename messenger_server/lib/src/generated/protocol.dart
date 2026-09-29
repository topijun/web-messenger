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
import 'package:serverpod/protocol.dart' as _i2;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i3;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i4;
import 'chats/chat.dart' as _i5;
import 'chats/chat_invitation.dart' as _i6;
import 'chats/chat_invitation_status.dart' as _i7;
import 'chats/chat_invitation_view.dart' as _i8;
import 'chats/chat_member.dart' as _i9;
import 'chats/chat_participant.dart' as _i10;
import 'chats/chat_participant_role.dart' as _i11;
import 'chats/chat_summary.dart' as _i12;
import 'chats/chat_type.dart' as _i13;
import 'chats/messenger_already_chat_participant_exception.dart' as _i14;
import 'chats/messenger_chat_not_found_exception.dart' as _i15;
import 'chats/messenger_direct_chat_already_exists_exception.dart' as _i16;
import 'chats/messenger_duplicate_invitation_exception.dart' as _i17;
import 'chats/messenger_invalid_chat_input_exception.dart' as _i18;
import 'chats/messenger_invitation_already_handled_exception.dart' as _i19;
import 'chats/messenger_invitation_not_found_exception.dart' as _i20;
import 'chats/messenger_not_chat_admin_exception.dart' as _i21;
import 'chats/messenger_not_chat_member_exception.dart' as _i22;
import 'chats/messenger_self_invitation_exception.dart' as _i23;
import 'chats/user_avatar_ref.dart' as _i24;
import 'devices/device.dart' as _i25;
import 'devices/device_platform.dart' as _i26;
import 'devices/messenger_device_not_found_exception.dart' as _i27;
import 'encryption/messenger_encrypted_data_exception.dart' as _i28;
import 'greetings/greeting.dart' as _i29;
import 'media/chat_media.dart' as _i30;
import 'media/media.dart' as _i31;
import 'media/media_type.dart' as _i32;
import 'media/messenger_invalid_media_exception.dart' as _i33;
import 'media/messenger_media_not_found_exception.dart' as _i34;
import 'media/profile_image.dart' as _i35;
import 'messages/chat_event.dart' as _i36;
import 'messages/chat_event_kind.dart' as _i37;
import 'messages/message.dart' as _i38;
import 'messages/message_history_page.dart' as _i39;
import 'messages/message_reaction.dart' as _i40;
import 'messages/message_reaction_view.dart' as _i41;
import 'messages/message_receipt.dart' as _i42;
import 'messages/message_type.dart' as _i43;
import 'messages/message_view.dart' as _i44;
import 'messages/messenger_message_not_found_exception.dart' as _i45;
import 'messages/messenger_not_message_owner_exception.dart' as _i46;
import 'messages/messenger_not_message_recipient_exception.dart' as _i47;
import 'messages/messenger_poll_not_found_exception.dart' as _i48;
import 'messages/poll.dart' as _i49;
import 'messages/poll_option.dart' as _i50;
import 'messages/poll_option_view.dart' as _i51;
import 'messages/poll_view.dart' as _i52;
import 'messages/poll_vote.dart' as _i53;
import 'profiles/messenger_invalid_profile_input_exception.dart' as _i54;
import 'profiles/profile.dart' as _i55;
import 'users/contact_search_relation.dart' as _i56;
import 'users/contact_search_result.dart' as _i57;
import 'users/messenger_account_required_exception.dart' as _i58;
import 'users/messenger_invalid_registration_input_exception.dart' as _i59;
import 'users/messenger_invalid_username_exception.dart' as _i60;
import 'users/messenger_registration_incomplete_exception.dart' as _i61;
import 'users/messenger_registration_request.dart' as _i62;
import 'users/messenger_user.dart' as _i63;
import 'users/messenger_user_already_exists_exception.dart' as _i64;
import 'users/messenger_user_not_found_exception.dart' as _i65;
import 'users/messenger_username_taken_exception.dart' as _i66;
import 'package:messenger_server/src/generated/chats/chat_summary.dart' as _i67;
import 'package:messenger_server/src/generated/chats/chat_member.dart' as _i68;
import 'package:messenger_server/src/generated/chats/chat_invitation_view.dart'
    as _i69;
import 'package:messenger_server/src/generated/devices/device.dart' as _i70;
import 'package:messenger_server/src/generated/messages/message_view.dart'
    as _i71;
import 'package:messenger_server/src/generated/messages/message_receipt.dart'
    as _i72;
export 'chats/chat.dart';
export 'chats/chat_invitation.dart';
export 'chats/chat_invitation_status.dart';
export 'chats/chat_invitation_view.dart';
export 'chats/chat_member.dart';
export 'chats/chat_participant.dart';
export 'chats/chat_participant_role.dart';
export 'chats/chat_summary.dart';
export 'chats/chat_type.dart';
export 'chats/messenger_already_chat_participant_exception.dart';
export 'chats/messenger_chat_not_found_exception.dart';
export 'chats/messenger_direct_chat_already_exists_exception.dart';
export 'chats/messenger_duplicate_invitation_exception.dart';
export 'chats/messenger_invalid_chat_input_exception.dart';
export 'chats/messenger_invitation_already_handled_exception.dart';
export 'chats/messenger_invitation_not_found_exception.dart';
export 'chats/messenger_not_chat_admin_exception.dart';
export 'chats/messenger_not_chat_member_exception.dart';
export 'chats/messenger_self_invitation_exception.dart';
export 'chats/user_avatar_ref.dart';
export 'devices/device.dart';
export 'devices/device_platform.dart';
export 'devices/messenger_device_not_found_exception.dart';
export 'encryption/messenger_encrypted_data_exception.dart';
export 'greetings/greeting.dart';
export 'media/chat_media.dart';
export 'media/media.dart';
export 'media/media_type.dart';
export 'media/messenger_invalid_media_exception.dart';
export 'media/messenger_media_not_found_exception.dart';
export 'media/profile_image.dart';
export 'messages/chat_event.dart';
export 'messages/chat_event_kind.dart';
export 'messages/message.dart';
export 'messages/message_history_page.dart';
export 'messages/message_reaction.dart';
export 'messages/message_reaction_view.dart';
export 'messages/message_receipt.dart';
export 'messages/message_type.dart';
export 'messages/message_view.dart';
export 'messages/messenger_message_not_found_exception.dart';
export 'messages/messenger_not_message_owner_exception.dart';
export 'messages/messenger_not_message_recipient_exception.dart';
export 'messages/messenger_poll_not_found_exception.dart';
export 'messages/poll.dart';
export 'messages/poll_option.dart';
export 'messages/poll_option_view.dart';
export 'messages/poll_view.dart';
export 'messages/poll_vote.dart';
export 'profiles/messenger_invalid_profile_input_exception.dart';
export 'profiles/profile.dart';
export 'users/contact_search_relation.dart';
export 'users/contact_search_result.dart';
export 'users/messenger_account_required_exception.dart';
export 'users/messenger_invalid_registration_input_exception.dart';
export 'users/messenger_invalid_username_exception.dart';
export 'users/messenger_registration_incomplete_exception.dart';
export 'users/messenger_registration_request.dart';
export 'users/messenger_user.dart';
export 'users/messenger_user_already_exists_exception.dart';
export 'users/messenger_user_not_found_exception.dart';
export 'users/messenger_username_taken_exception.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'messenger_chat',
      dartName: 'Chat',
      schema: 'public',
      module: 'messenger',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'messenger_chat_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'type',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ChatType',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'lastMessageAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'messenger_chat_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'messenger_chat_last_message_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'lastMessageAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'messenger_chat_invitation',
      dartName: 'ChatInvitation',
      schema: 'public',
      module: 'messenger',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault:
              'nextval(\'messenger_chat_invitation_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'chatId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'senderId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'receiverId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'status',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ChatInvitationStatus',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_chat_invitation_fk_0',
          columns: ['chatId'],
          referenceTable: 'messenger_chat',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_chat_invitation_fk_1',
          columns: ['senderId'],
          referenceTable: 'messenger_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_chat_invitation_fk_2',
          columns: ['receiverId'],
          referenceTable: 'messenger_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'messenger_chat_invitation_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'messenger_chat_invitation_receiver_status_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'receiverId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'status',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'messenger_chat_invitation_sender_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'senderId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'messenger_chat_participant',
      dartName: 'ChatParticipant',
      schema: 'public',
      module: 'messenger',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault:
              'nextval(\'messenger_chat_participant_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'chatId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'role',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ChatParticipantRole',
        ),
        _i2.ColumnDefinition(
          name: 'joinedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'archived',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'notificationsMuted',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_chat_participant_fk_0',
          columns: ['chatId'],
          referenceTable: 'messenger_chat',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_chat_participant_fk_1',
          columns: ['userId'],
          referenceTable: 'messenger_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'messenger_chat_participant_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'messenger_chat_participant_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'chatId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'messenger_chat_participant_user_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'messenger_device',
      dartName: 'Device',
      schema: 'public',
      module: 'messenger',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'messenger_device_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'clientId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'platform',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:DevicePlatform',
        ),
        _i2.ColumnDefinition(
          name: 'pushToken',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'lastSeenAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_device_fk_0',
          columns: ['userId'],
          referenceTable: 'messenger_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'messenger_device_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'messenger_device_client_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'clientId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'messenger_device_user_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'messenger_media',
      dartName: 'Media',
      schema: 'public',
      module: 'messenger',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'messenger_media_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'type',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:MediaType',
        ),
        _i2.ColumnDefinition(
          name: 'mimeType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'size',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'encryptedData',
          columnType: _i2.ColumnType.bytea,
          isNullable: false,
          dartType: 'dart:typed_data:ByteData',
        ),
        _i2.ColumnDefinition(
          name: 'thumbnailMediaId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_media_fk_0',
          columns: ['userId'],
          referenceTable: 'messenger_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'messenger_media_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'messenger_media_user_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'messenger_message',
      dartName: 'Message',
      schema: 'public',
      module: 'messenger',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'messenger_message_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'chatId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'senderId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'type',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:MessageType',
        ),
        _i2.ColumnDefinition(
          name: 'encryptedText',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'mediaId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'pollId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'editedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'deletedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_message_fk_0',
          columns: ['chatId'],
          referenceTable: 'messenger_chat',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_message_fk_1',
          columns: ['senderId'],
          referenceTable: 'messenger_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_message_fk_2',
          columns: ['mediaId'],
          referenceTable: 'messenger_media',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_message_fk_3',
          columns: ['pollId'],
          referenceTable: 'messenger_poll',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'messenger_message_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'messenger_message_chat_created_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'chatId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'messenger_message_reaction',
      dartName: 'MessageReaction',
      schema: 'public',
      module: 'messenger',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault:
              'nextval(\'messenger_message_reaction_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'messageId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'emoji',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_message_reaction_fk_0',
          columns: ['messageId'],
          referenceTable: 'messenger_message',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_message_reaction_fk_1',
          columns: ['userId'],
          referenceTable: 'messenger_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'messenger_message_reaction_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'messenger_message_reaction_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'messageId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'emoji',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'messenger_message_reaction_message_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'messageId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'messenger_message_receipt',
      dartName: 'MessageReceipt',
      schema: 'public',
      module: 'messenger',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault:
              'nextval(\'messenger_message_receipt_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'messageId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'deliveredAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'readAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_message_receipt_fk_0',
          columns: ['messageId'],
          referenceTable: 'messenger_message',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_message_receipt_fk_1',
          columns: ['userId'],
          referenceTable: 'messenger_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'messenger_message_receipt_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'messenger_message_receipt_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'messageId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'messenger_message_receipt_user_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'messenger_poll',
      dartName: 'Poll',
      schema: 'public',
      module: 'messenger',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'messenger_poll_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'question',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'anonymous',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'createdById',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_poll_fk_0',
          columns: ['createdById'],
          referenceTable: 'messenger_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'messenger_poll_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'messenger_poll_created_by_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'createdById',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'messenger_poll_option',
      dartName: 'PollOption',
      schema: 'public',
      module: 'messenger',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'messenger_poll_option_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'pollId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'text',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'position',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_poll_option_fk_0',
          columns: ['pollId'],
          referenceTable: 'messenger_poll',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'messenger_poll_option_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'messenger_poll_option_order_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'pollId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'position',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'messenger_poll_vote',
      dartName: 'PollVote',
      schema: 'public',
      module: 'messenger',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'messenger_poll_vote_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'pollId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'optionId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_poll_vote_fk_0',
          columns: ['pollId'],
          referenceTable: 'messenger_poll',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_poll_vote_fk_1',
          columns: ['optionId'],
          referenceTable: 'messenger_poll_option',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_poll_vote_fk_2',
          columns: ['userId'],
          referenceTable: 'messenger_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'messenger_poll_vote_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'messenger_poll_vote_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'pollId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'messenger_poll_vote_option_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'optionId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'messenger_profile',
      dartName: 'Profile',
      schema: 'public',
      module: 'messenger',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'messenger_profile_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'aboutMe',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'profileImageId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_profile_fk_0',
          columns: ['userId'],
          referenceTable: 'messenger_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_profile_fk_1',
          columns: ['profileImageId'],
          referenceTable: 'messenger_media',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'messenger_profile_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'messenger_profile_user_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'messenger_registration_request',
      dartName: 'MessengerRegistrationRequest',
      schema: 'public',
      module: 'messenger',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault:
              'nextval(\'messenger_registration_request_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'accountRequestId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'email',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'username',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'usernameNormalized',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'messenger_registration_request_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName:
              'messenger_registration_request_account_request_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'accountRequestId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'messenger_registration_request_email_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'email',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName:
              'messenger_registration_request_username_normalized_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'usernameNormalized',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'messenger_user',
      dartName: 'MessengerUser',
      schema: 'public',
      module: 'messenger',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'messenger_user_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'authUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'username',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'usernameNormalized',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'messenger_user_fk_0',
          columns: ['authUserId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'messenger_user_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'messenger_user_auth_user_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'messenger_user_username_normalized_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'usernameNormalized',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._i3.Protocol.targetTableDefinitions,
    ..._i4.Protocol.targetTableDefinitions,
    ..._i2.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i5.Chat) {
      return _i5.Chat.fromJson(data) as T;
    }
    if (t == _i6.ChatInvitation) {
      return _i6.ChatInvitation.fromJson(data) as T;
    }
    if (t == _i7.ChatInvitationStatus) {
      return _i7.ChatInvitationStatus.fromJson(data) as T;
    }
    if (t == _i8.ChatInvitationView) {
      return _i8.ChatInvitationView.fromJson(data) as T;
    }
    if (t == _i9.ChatMember) {
      return _i9.ChatMember.fromJson(data) as T;
    }
    if (t == _i10.ChatParticipant) {
      return _i10.ChatParticipant.fromJson(data) as T;
    }
    if (t == _i11.ChatParticipantRole) {
      return _i11.ChatParticipantRole.fromJson(data) as T;
    }
    if (t == _i12.ChatSummary) {
      return _i12.ChatSummary.fromJson(data) as T;
    }
    if (t == _i13.ChatType) {
      return _i13.ChatType.fromJson(data) as T;
    }
    if (t == _i14.MessengerAlreadyChatParticipantException) {
      return _i14.MessengerAlreadyChatParticipantException.fromJson(data) as T;
    }
    if (t == _i15.MessengerChatNotFoundException) {
      return _i15.MessengerChatNotFoundException.fromJson(data) as T;
    }
    if (t == _i16.MessengerDirectChatAlreadyExistsException) {
      return _i16.MessengerDirectChatAlreadyExistsException.fromJson(data) as T;
    }
    if (t == _i17.MessengerDuplicateInvitationException) {
      return _i17.MessengerDuplicateInvitationException.fromJson(data) as T;
    }
    if (t == _i18.MessengerInvalidChatInputException) {
      return _i18.MessengerInvalidChatInputException.fromJson(data) as T;
    }
    if (t == _i19.MessengerInvitationAlreadyHandledException) {
      return _i19.MessengerInvitationAlreadyHandledException.fromJson(data)
          as T;
    }
    if (t == _i20.MessengerInvitationNotFoundException) {
      return _i20.MessengerInvitationNotFoundException.fromJson(data) as T;
    }
    if (t == _i21.MessengerNotChatAdminException) {
      return _i21.MessengerNotChatAdminException.fromJson(data) as T;
    }
    if (t == _i22.MessengerNotChatMemberException) {
      return _i22.MessengerNotChatMemberException.fromJson(data) as T;
    }
    if (t == _i23.MessengerSelfInvitationException) {
      return _i23.MessengerSelfInvitationException.fromJson(data) as T;
    }
    if (t == _i24.UserAvatarRef) {
      return _i24.UserAvatarRef.fromJson(data) as T;
    }
    if (t == _i25.Device) {
      return _i25.Device.fromJson(data) as T;
    }
    if (t == _i26.DevicePlatform) {
      return _i26.DevicePlatform.fromJson(data) as T;
    }
    if (t == _i27.MessengerDeviceNotFoundException) {
      return _i27.MessengerDeviceNotFoundException.fromJson(data) as T;
    }
    if (t == _i28.MessengerEncryptedDataException) {
      return _i28.MessengerEncryptedDataException.fromJson(data) as T;
    }
    if (t == _i29.Greeting) {
      return _i29.Greeting.fromJson(data) as T;
    }
    if (t == _i30.ChatMedia) {
      return _i30.ChatMedia.fromJson(data) as T;
    }
    if (t == _i31.Media) {
      return _i31.Media.fromJson(data) as T;
    }
    if (t == _i32.MediaType) {
      return _i32.MediaType.fromJson(data) as T;
    }
    if (t == _i33.MessengerInvalidMediaException) {
      return _i33.MessengerInvalidMediaException.fromJson(data) as T;
    }
    if (t == _i34.MessengerMediaNotFoundException) {
      return _i34.MessengerMediaNotFoundException.fromJson(data) as T;
    }
    if (t == _i35.ProfileImage) {
      return _i35.ProfileImage.fromJson(data) as T;
    }
    if (t == _i36.ChatEvent) {
      return _i36.ChatEvent.fromJson(data) as T;
    }
    if (t == _i37.ChatEventKind) {
      return _i37.ChatEventKind.fromJson(data) as T;
    }
    if (t == _i38.Message) {
      return _i38.Message.fromJson(data) as T;
    }
    if (t == _i39.MessageHistoryPage) {
      return _i39.MessageHistoryPage.fromJson(data) as T;
    }
    if (t == _i40.MessageReaction) {
      return _i40.MessageReaction.fromJson(data) as T;
    }
    if (t == _i41.MessageReactionView) {
      return _i41.MessageReactionView.fromJson(data) as T;
    }
    if (t == _i42.MessageReceipt) {
      return _i42.MessageReceipt.fromJson(data) as T;
    }
    if (t == _i43.MessageType) {
      return _i43.MessageType.fromJson(data) as T;
    }
    if (t == _i44.MessageView) {
      return _i44.MessageView.fromJson(data) as T;
    }
    if (t == _i45.MessengerMessageNotFoundException) {
      return _i45.MessengerMessageNotFoundException.fromJson(data) as T;
    }
    if (t == _i46.MessengerNotMessageOwnerException) {
      return _i46.MessengerNotMessageOwnerException.fromJson(data) as T;
    }
    if (t == _i47.MessengerNotMessageRecipientException) {
      return _i47.MessengerNotMessageRecipientException.fromJson(data) as T;
    }
    if (t == _i48.MessengerPollNotFoundException) {
      return _i48.MessengerPollNotFoundException.fromJson(data) as T;
    }
    if (t == _i49.Poll) {
      return _i49.Poll.fromJson(data) as T;
    }
    if (t == _i50.PollOption) {
      return _i50.PollOption.fromJson(data) as T;
    }
    if (t == _i51.PollOptionView) {
      return _i51.PollOptionView.fromJson(data) as T;
    }
    if (t == _i52.PollView) {
      return _i52.PollView.fromJson(data) as T;
    }
    if (t == _i53.PollVote) {
      return _i53.PollVote.fromJson(data) as T;
    }
    if (t == _i54.MessengerInvalidProfileInputException) {
      return _i54.MessengerInvalidProfileInputException.fromJson(data) as T;
    }
    if (t == _i55.Profile) {
      return _i55.Profile.fromJson(data) as T;
    }
    if (t == _i56.ContactSearchRelation) {
      return _i56.ContactSearchRelation.fromJson(data) as T;
    }
    if (t == _i57.ContactSearchResult) {
      return _i57.ContactSearchResult.fromJson(data) as T;
    }
    if (t == _i58.MessengerAccountRequiredException) {
      return _i58.MessengerAccountRequiredException.fromJson(data) as T;
    }
    if (t == _i59.MessengerInvalidRegistrationInputException) {
      return _i59.MessengerInvalidRegistrationInputException.fromJson(data)
          as T;
    }
    if (t == _i60.MessengerInvalidUsernameException) {
      return _i60.MessengerInvalidUsernameException.fromJson(data) as T;
    }
    if (t == _i61.MessengerRegistrationIncompleteException) {
      return _i61.MessengerRegistrationIncompleteException.fromJson(data) as T;
    }
    if (t == _i62.MessengerRegistrationRequest) {
      return _i62.MessengerRegistrationRequest.fromJson(data) as T;
    }
    if (t == _i63.MessengerUser) {
      return _i63.MessengerUser.fromJson(data) as T;
    }
    if (t == _i64.MessengerUserAlreadyExistsException) {
      return _i64.MessengerUserAlreadyExistsException.fromJson(data) as T;
    }
    if (t == _i65.MessengerUserNotFoundException) {
      return _i65.MessengerUserNotFoundException.fromJson(data) as T;
    }
    if (t == _i66.MessengerUsernameTakenException) {
      return _i66.MessengerUsernameTakenException.fromJson(data) as T;
    }
    if (t == _i1.getType<_i5.Chat?>()) {
      return (data != null ? _i5.Chat.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.ChatInvitation?>()) {
      return (data != null ? _i6.ChatInvitation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.ChatInvitationStatus?>()) {
      return (data != null ? _i7.ChatInvitationStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i8.ChatInvitationView?>()) {
      return (data != null ? _i8.ChatInvitationView.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.ChatMember?>()) {
      return (data != null ? _i9.ChatMember.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.ChatParticipant?>()) {
      return (data != null ? _i10.ChatParticipant.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.ChatParticipantRole?>()) {
      return (data != null ? _i11.ChatParticipantRole.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i12.ChatSummary?>()) {
      return (data != null ? _i12.ChatSummary.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.ChatType?>()) {
      return (data != null ? _i13.ChatType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.MessengerAlreadyChatParticipantException?>()) {
      return (data != null
              ? _i14.MessengerAlreadyChatParticipantException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i15.MessengerChatNotFoundException?>()) {
      return (data != null
              ? _i15.MessengerChatNotFoundException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i16.MessengerDirectChatAlreadyExistsException?>()) {
      return (data != null
              ? _i16.MessengerDirectChatAlreadyExistsException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i17.MessengerDuplicateInvitationException?>()) {
      return (data != null
              ? _i17.MessengerDuplicateInvitationException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i18.MessengerInvalidChatInputException?>()) {
      return (data != null
              ? _i18.MessengerInvalidChatInputException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i19.MessengerInvitationAlreadyHandledException?>()) {
      return (data != null
              ? _i19.MessengerInvitationAlreadyHandledException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i20.MessengerInvitationNotFoundException?>()) {
      return (data != null
              ? _i20.MessengerInvitationNotFoundException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i21.MessengerNotChatAdminException?>()) {
      return (data != null
              ? _i21.MessengerNotChatAdminException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i22.MessengerNotChatMemberException?>()) {
      return (data != null
              ? _i22.MessengerNotChatMemberException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i23.MessengerSelfInvitationException?>()) {
      return (data != null
              ? _i23.MessengerSelfInvitationException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i24.UserAvatarRef?>()) {
      return (data != null ? _i24.UserAvatarRef.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.Device?>()) {
      return (data != null ? _i25.Device.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.DevicePlatform?>()) {
      return (data != null ? _i26.DevicePlatform.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.MessengerDeviceNotFoundException?>()) {
      return (data != null
              ? _i27.MessengerDeviceNotFoundException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i28.MessengerEncryptedDataException?>()) {
      return (data != null
              ? _i28.MessengerEncryptedDataException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i29.Greeting?>()) {
      return (data != null ? _i29.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i30.ChatMedia?>()) {
      return (data != null ? _i30.ChatMedia.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.Media?>()) {
      return (data != null ? _i31.Media.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i32.MediaType?>()) {
      return (data != null ? _i32.MediaType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.MessengerInvalidMediaException?>()) {
      return (data != null
              ? _i33.MessengerInvalidMediaException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i34.MessengerMediaNotFoundException?>()) {
      return (data != null
              ? _i34.MessengerMediaNotFoundException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i35.ProfileImage?>()) {
      return (data != null ? _i35.ProfileImage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.ChatEvent?>()) {
      return (data != null ? _i36.ChatEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i37.ChatEventKind?>()) {
      return (data != null ? _i37.ChatEventKind.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.Message?>()) {
      return (data != null ? _i38.Message.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i39.MessageHistoryPage?>()) {
      return (data != null ? _i39.MessageHistoryPage.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i40.MessageReaction?>()) {
      return (data != null ? _i40.MessageReaction.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i41.MessageReactionView?>()) {
      return (data != null ? _i41.MessageReactionView.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i42.MessageReceipt?>()) {
      return (data != null ? _i42.MessageReceipt.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i43.MessageType?>()) {
      return (data != null ? _i43.MessageType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i44.MessageView?>()) {
      return (data != null ? _i44.MessageView.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i45.MessengerMessageNotFoundException?>()) {
      return (data != null
              ? _i45.MessengerMessageNotFoundException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i46.MessengerNotMessageOwnerException?>()) {
      return (data != null
              ? _i46.MessengerNotMessageOwnerException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i47.MessengerNotMessageRecipientException?>()) {
      return (data != null
              ? _i47.MessengerNotMessageRecipientException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i48.MessengerPollNotFoundException?>()) {
      return (data != null
              ? _i48.MessengerPollNotFoundException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i49.Poll?>()) {
      return (data != null ? _i49.Poll.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i50.PollOption?>()) {
      return (data != null ? _i50.PollOption.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i51.PollOptionView?>()) {
      return (data != null ? _i51.PollOptionView.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i52.PollView?>()) {
      return (data != null ? _i52.PollView.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i53.PollVote?>()) {
      return (data != null ? _i53.PollVote.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i54.MessengerInvalidProfileInputException?>()) {
      return (data != null
              ? _i54.MessengerInvalidProfileInputException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i55.Profile?>()) {
      return (data != null ? _i55.Profile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i56.ContactSearchRelation?>()) {
      return (data != null ? _i56.ContactSearchRelation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i57.ContactSearchResult?>()) {
      return (data != null ? _i57.ContactSearchResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i58.MessengerAccountRequiredException?>()) {
      return (data != null
              ? _i58.MessengerAccountRequiredException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i59.MessengerInvalidRegistrationInputException?>()) {
      return (data != null
              ? _i59.MessengerInvalidRegistrationInputException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i60.MessengerInvalidUsernameException?>()) {
      return (data != null
              ? _i60.MessengerInvalidUsernameException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i61.MessengerRegistrationIncompleteException?>()) {
      return (data != null
              ? _i61.MessengerRegistrationIncompleteException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i62.MessengerRegistrationRequest?>()) {
      return (data != null
              ? _i62.MessengerRegistrationRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i63.MessengerUser?>()) {
      return (data != null ? _i63.MessengerUser.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i64.MessengerUserAlreadyExistsException?>()) {
      return (data != null
              ? _i64.MessengerUserAlreadyExistsException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i65.MessengerUserNotFoundException?>()) {
      return (data != null
              ? _i65.MessengerUserNotFoundException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i66.MessengerUsernameTakenException?>()) {
      return (data != null
              ? _i66.MessengerUsernameTakenException.fromJson(data)
              : null)
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i24.UserAvatarRef>) {
      return (data as List)
              .map((e) => deserialize<_i24.UserAvatarRef>(e))
              .toList()
          as T;
    }
    if (t == List<_i42.MessageReceipt>) {
      return (data as List)
              .map((e) => deserialize<_i42.MessageReceipt>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i42.MessageReceipt>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i42.MessageReceipt>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i44.MessageView>) {
      return (data as List)
              .map((e) => deserialize<_i44.MessageView>(e))
              .toList()
          as T;
    }
    if (t == List<_i41.MessageReactionView>) {
      return (data as List)
              .map((e) => deserialize<_i41.MessageReactionView>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i41.MessageReactionView>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i41.MessageReactionView>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i51.PollOptionView>) {
      return (data as List)
              .map((e) => deserialize<_i51.PollOptionView>(e))
              .toList()
          as T;
    }
    if (t == List<_i6.ChatInvitation>) {
      return (data as List)
              .map((e) => deserialize<_i6.ChatInvitation>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i6.ChatInvitation>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i6.ChatInvitation>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i67.ChatSummary>) {
      return (data as List)
              .map((e) => deserialize<_i67.ChatSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_i68.ChatMember>) {
      return (data as List).map((e) => deserialize<_i68.ChatMember>(e)).toList()
          as T;
    }
    if (t == List<_i69.ChatInvitationView>) {
      return (data as List)
              .map((e) => deserialize<_i69.ChatInvitationView>(e))
              .toList()
          as T;
    }
    if (t == List<_i70.Device>) {
      return (data as List).map((e) => deserialize<_i70.Device>(e)).toList()
          as T;
    }
    if (t == List<_i71.MessageView>) {
      return (data as List)
              .map((e) => deserialize<_i71.MessageView>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i72.MessageReceipt>) {
      return (data as List)
              .map((e) => deserialize<_i72.MessageReceipt>(e))
              .toList()
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    try {
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i4.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i5.Chat => 'Chat',
      _i6.ChatInvitation => 'ChatInvitation',
      _i7.ChatInvitationStatus => 'ChatInvitationStatus',
      _i8.ChatInvitationView => 'ChatInvitationView',
      _i9.ChatMember => 'ChatMember',
      _i10.ChatParticipant => 'ChatParticipant',
      _i11.ChatParticipantRole => 'ChatParticipantRole',
      _i12.ChatSummary => 'ChatSummary',
      _i13.ChatType => 'ChatType',
      _i14.MessengerAlreadyChatParticipantException =>
        'MessengerAlreadyChatParticipantException',
      _i15.MessengerChatNotFoundException => 'MessengerChatNotFoundException',
      _i16.MessengerDirectChatAlreadyExistsException =>
        'MessengerDirectChatAlreadyExistsException',
      _i17.MessengerDuplicateInvitationException =>
        'MessengerDuplicateInvitationException',
      _i18.MessengerInvalidChatInputException =>
        'MessengerInvalidChatInputException',
      _i19.MessengerInvitationAlreadyHandledException =>
        'MessengerInvitationAlreadyHandledException',
      _i20.MessengerInvitationNotFoundException =>
        'MessengerInvitationNotFoundException',
      _i21.MessengerNotChatAdminException => 'MessengerNotChatAdminException',
      _i22.MessengerNotChatMemberException => 'MessengerNotChatMemberException',
      _i23.MessengerSelfInvitationException =>
        'MessengerSelfInvitationException',
      _i24.UserAvatarRef => 'UserAvatarRef',
      _i25.Device => 'Device',
      _i26.DevicePlatform => 'DevicePlatform',
      _i27.MessengerDeviceNotFoundException =>
        'MessengerDeviceNotFoundException',
      _i28.MessengerEncryptedDataException => 'MessengerEncryptedDataException',
      _i29.Greeting => 'Greeting',
      _i30.ChatMedia => 'ChatMedia',
      _i31.Media => 'Media',
      _i32.MediaType => 'MediaType',
      _i33.MessengerInvalidMediaException => 'MessengerInvalidMediaException',
      _i34.MessengerMediaNotFoundException => 'MessengerMediaNotFoundException',
      _i35.ProfileImage => 'ProfileImage',
      _i36.ChatEvent => 'ChatEvent',
      _i37.ChatEventKind => 'ChatEventKind',
      _i38.Message => 'Message',
      _i39.MessageHistoryPage => 'MessageHistoryPage',
      _i40.MessageReaction => 'MessageReaction',
      _i41.MessageReactionView => 'MessageReactionView',
      _i42.MessageReceipt => 'MessageReceipt',
      _i43.MessageType => 'MessageType',
      _i44.MessageView => 'MessageView',
      _i45.MessengerMessageNotFoundException =>
        'MessengerMessageNotFoundException',
      _i46.MessengerNotMessageOwnerException =>
        'MessengerNotMessageOwnerException',
      _i47.MessengerNotMessageRecipientException =>
        'MessengerNotMessageRecipientException',
      _i48.MessengerPollNotFoundException => 'MessengerPollNotFoundException',
      _i49.Poll => 'Poll',
      _i50.PollOption => 'PollOption',
      _i51.PollOptionView => 'PollOptionView',
      _i52.PollView => 'PollView',
      _i53.PollVote => 'PollVote',
      _i54.MessengerInvalidProfileInputException =>
        'MessengerInvalidProfileInputException',
      _i55.Profile => 'Profile',
      _i56.ContactSearchRelation => 'ContactSearchRelation',
      _i57.ContactSearchResult => 'ContactSearchResult',
      _i58.MessengerAccountRequiredException =>
        'MessengerAccountRequiredException',
      _i59.MessengerInvalidRegistrationInputException =>
        'MessengerInvalidRegistrationInputException',
      _i60.MessengerInvalidUsernameException =>
        'MessengerInvalidUsernameException',
      _i61.MessengerRegistrationIncompleteException =>
        'MessengerRegistrationIncompleteException',
      _i62.MessengerRegistrationRequest => 'MessengerRegistrationRequest',
      _i63.MessengerUser => 'MessengerUser',
      _i64.MessengerUserAlreadyExistsException =>
        'MessengerUserAlreadyExistsException',
      _i65.MessengerUserNotFoundException => 'MessengerUserNotFoundException',
      _i66.MessengerUsernameTakenException => 'MessengerUsernameTakenException',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('messenger.', '');
    }

    switch (data) {
      case _i5.Chat():
        return 'Chat';
      case _i6.ChatInvitation():
        return 'ChatInvitation';
      case _i7.ChatInvitationStatus():
        return 'ChatInvitationStatus';
      case _i8.ChatInvitationView():
        return 'ChatInvitationView';
      case _i9.ChatMember():
        return 'ChatMember';
      case _i10.ChatParticipant():
        return 'ChatParticipant';
      case _i11.ChatParticipantRole():
        return 'ChatParticipantRole';
      case _i12.ChatSummary():
        return 'ChatSummary';
      case _i13.ChatType():
        return 'ChatType';
      case _i14.MessengerAlreadyChatParticipantException():
        return 'MessengerAlreadyChatParticipantException';
      case _i15.MessengerChatNotFoundException():
        return 'MessengerChatNotFoundException';
      case _i16.MessengerDirectChatAlreadyExistsException():
        return 'MessengerDirectChatAlreadyExistsException';
      case _i17.MessengerDuplicateInvitationException():
        return 'MessengerDuplicateInvitationException';
      case _i18.MessengerInvalidChatInputException():
        return 'MessengerInvalidChatInputException';
      case _i19.MessengerInvitationAlreadyHandledException():
        return 'MessengerInvitationAlreadyHandledException';
      case _i20.MessengerInvitationNotFoundException():
        return 'MessengerInvitationNotFoundException';
      case _i21.MessengerNotChatAdminException():
        return 'MessengerNotChatAdminException';
      case _i22.MessengerNotChatMemberException():
        return 'MessengerNotChatMemberException';
      case _i23.MessengerSelfInvitationException():
        return 'MessengerSelfInvitationException';
      case _i24.UserAvatarRef():
        return 'UserAvatarRef';
      case _i25.Device():
        return 'Device';
      case _i26.DevicePlatform():
        return 'DevicePlatform';
      case _i27.MessengerDeviceNotFoundException():
        return 'MessengerDeviceNotFoundException';
      case _i28.MessengerEncryptedDataException():
        return 'MessengerEncryptedDataException';
      case _i29.Greeting():
        return 'Greeting';
      case _i30.ChatMedia():
        return 'ChatMedia';
      case _i31.Media():
        return 'Media';
      case _i32.MediaType():
        return 'MediaType';
      case _i33.MessengerInvalidMediaException():
        return 'MessengerInvalidMediaException';
      case _i34.MessengerMediaNotFoundException():
        return 'MessengerMediaNotFoundException';
      case _i35.ProfileImage():
        return 'ProfileImage';
      case _i36.ChatEvent():
        return 'ChatEvent';
      case _i37.ChatEventKind():
        return 'ChatEventKind';
      case _i38.Message():
        return 'Message';
      case _i39.MessageHistoryPage():
        return 'MessageHistoryPage';
      case _i40.MessageReaction():
        return 'MessageReaction';
      case _i41.MessageReactionView():
        return 'MessageReactionView';
      case _i42.MessageReceipt():
        return 'MessageReceipt';
      case _i43.MessageType():
        return 'MessageType';
      case _i44.MessageView():
        return 'MessageView';
      case _i45.MessengerMessageNotFoundException():
        return 'MessengerMessageNotFoundException';
      case _i46.MessengerNotMessageOwnerException():
        return 'MessengerNotMessageOwnerException';
      case _i47.MessengerNotMessageRecipientException():
        return 'MessengerNotMessageRecipientException';
      case _i48.MessengerPollNotFoundException():
        return 'MessengerPollNotFoundException';
      case _i49.Poll():
        return 'Poll';
      case _i50.PollOption():
        return 'PollOption';
      case _i51.PollOptionView():
        return 'PollOptionView';
      case _i52.PollView():
        return 'PollView';
      case _i53.PollVote():
        return 'PollVote';
      case _i54.MessengerInvalidProfileInputException():
        return 'MessengerInvalidProfileInputException';
      case _i55.Profile():
        return 'Profile';
      case _i56.ContactSearchRelation():
        return 'ContactSearchRelation';
      case _i57.ContactSearchResult():
        return 'ContactSearchResult';
      case _i58.MessengerAccountRequiredException():
        return 'MessengerAccountRequiredException';
      case _i59.MessengerInvalidRegistrationInputException():
        return 'MessengerInvalidRegistrationInputException';
      case _i60.MessengerInvalidUsernameException():
        return 'MessengerInvalidUsernameException';
      case _i61.MessengerRegistrationIncompleteException():
        return 'MessengerRegistrationIncompleteException';
      case _i62.MessengerRegistrationRequest():
        return 'MessengerRegistrationRequest';
      case _i63.MessengerUser():
        return 'MessengerUser';
      case _i64.MessengerUserAlreadyExistsException():
        return 'MessengerUserAlreadyExistsException';
      case _i65.MessengerUserNotFoundException():
        return 'MessengerUserNotFoundException';
      case _i66.MessengerUsernameTakenException():
        return 'MessengerUsernameTakenException';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    className = _i3.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i4.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Chat') {
      return deserialize<_i5.Chat>(data['data']);
    }
    if (dataClassName == 'ChatInvitation') {
      return deserialize<_i6.ChatInvitation>(data['data']);
    }
    if (dataClassName == 'ChatInvitationStatus') {
      return deserialize<_i7.ChatInvitationStatus>(data['data']);
    }
    if (dataClassName == 'ChatInvitationView') {
      return deserialize<_i8.ChatInvitationView>(data['data']);
    }
    if (dataClassName == 'ChatMember') {
      return deserialize<_i9.ChatMember>(data['data']);
    }
    if (dataClassName == 'ChatParticipant') {
      return deserialize<_i10.ChatParticipant>(data['data']);
    }
    if (dataClassName == 'ChatParticipantRole') {
      return deserialize<_i11.ChatParticipantRole>(data['data']);
    }
    if (dataClassName == 'ChatSummary') {
      return deserialize<_i12.ChatSummary>(data['data']);
    }
    if (dataClassName == 'ChatType') {
      return deserialize<_i13.ChatType>(data['data']);
    }
    if (dataClassName == 'MessengerAlreadyChatParticipantException') {
      return deserialize<_i14.MessengerAlreadyChatParticipantException>(
        data['data'],
      );
    }
    if (dataClassName == 'MessengerChatNotFoundException') {
      return deserialize<_i15.MessengerChatNotFoundException>(data['data']);
    }
    if (dataClassName == 'MessengerDirectChatAlreadyExistsException') {
      return deserialize<_i16.MessengerDirectChatAlreadyExistsException>(
        data['data'],
      );
    }
    if (dataClassName == 'MessengerDuplicateInvitationException') {
      return deserialize<_i17.MessengerDuplicateInvitationException>(
        data['data'],
      );
    }
    if (dataClassName == 'MessengerInvalidChatInputException') {
      return deserialize<_i18.MessengerInvalidChatInputException>(data['data']);
    }
    if (dataClassName == 'MessengerInvitationAlreadyHandledException') {
      return deserialize<_i19.MessengerInvitationAlreadyHandledException>(
        data['data'],
      );
    }
    if (dataClassName == 'MessengerInvitationNotFoundException') {
      return deserialize<_i20.MessengerInvitationNotFoundException>(
        data['data'],
      );
    }
    if (dataClassName == 'MessengerNotChatAdminException') {
      return deserialize<_i21.MessengerNotChatAdminException>(data['data']);
    }
    if (dataClassName == 'MessengerNotChatMemberException') {
      return deserialize<_i22.MessengerNotChatMemberException>(data['data']);
    }
    if (dataClassName == 'MessengerSelfInvitationException') {
      return deserialize<_i23.MessengerSelfInvitationException>(data['data']);
    }
    if (dataClassName == 'UserAvatarRef') {
      return deserialize<_i24.UserAvatarRef>(data['data']);
    }
    if (dataClassName == 'Device') {
      return deserialize<_i25.Device>(data['data']);
    }
    if (dataClassName == 'DevicePlatform') {
      return deserialize<_i26.DevicePlatform>(data['data']);
    }
    if (dataClassName == 'MessengerDeviceNotFoundException') {
      return deserialize<_i27.MessengerDeviceNotFoundException>(data['data']);
    }
    if (dataClassName == 'MessengerEncryptedDataException') {
      return deserialize<_i28.MessengerEncryptedDataException>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i29.Greeting>(data['data']);
    }
    if (dataClassName == 'ChatMedia') {
      return deserialize<_i30.ChatMedia>(data['data']);
    }
    if (dataClassName == 'Media') {
      return deserialize<_i31.Media>(data['data']);
    }
    if (dataClassName == 'MediaType') {
      return deserialize<_i32.MediaType>(data['data']);
    }
    if (dataClassName == 'MessengerInvalidMediaException') {
      return deserialize<_i33.MessengerInvalidMediaException>(data['data']);
    }
    if (dataClassName == 'MessengerMediaNotFoundException') {
      return deserialize<_i34.MessengerMediaNotFoundException>(data['data']);
    }
    if (dataClassName == 'ProfileImage') {
      return deserialize<_i35.ProfileImage>(data['data']);
    }
    if (dataClassName == 'ChatEvent') {
      return deserialize<_i36.ChatEvent>(data['data']);
    }
    if (dataClassName == 'ChatEventKind') {
      return deserialize<_i37.ChatEventKind>(data['data']);
    }
    if (dataClassName == 'Message') {
      return deserialize<_i38.Message>(data['data']);
    }
    if (dataClassName == 'MessageHistoryPage') {
      return deserialize<_i39.MessageHistoryPage>(data['data']);
    }
    if (dataClassName == 'MessageReaction') {
      return deserialize<_i40.MessageReaction>(data['data']);
    }
    if (dataClassName == 'MessageReactionView') {
      return deserialize<_i41.MessageReactionView>(data['data']);
    }
    if (dataClassName == 'MessageReceipt') {
      return deserialize<_i42.MessageReceipt>(data['data']);
    }
    if (dataClassName == 'MessageType') {
      return deserialize<_i43.MessageType>(data['data']);
    }
    if (dataClassName == 'MessageView') {
      return deserialize<_i44.MessageView>(data['data']);
    }
    if (dataClassName == 'MessengerMessageNotFoundException') {
      return deserialize<_i45.MessengerMessageNotFoundException>(data['data']);
    }
    if (dataClassName == 'MessengerNotMessageOwnerException') {
      return deserialize<_i46.MessengerNotMessageOwnerException>(data['data']);
    }
    if (dataClassName == 'MessengerNotMessageRecipientException') {
      return deserialize<_i47.MessengerNotMessageRecipientException>(
        data['data'],
      );
    }
    if (dataClassName == 'MessengerPollNotFoundException') {
      return deserialize<_i48.MessengerPollNotFoundException>(data['data']);
    }
    if (dataClassName == 'Poll') {
      return deserialize<_i49.Poll>(data['data']);
    }
    if (dataClassName == 'PollOption') {
      return deserialize<_i50.PollOption>(data['data']);
    }
    if (dataClassName == 'PollOptionView') {
      return deserialize<_i51.PollOptionView>(data['data']);
    }
    if (dataClassName == 'PollView') {
      return deserialize<_i52.PollView>(data['data']);
    }
    if (dataClassName == 'PollVote') {
      return deserialize<_i53.PollVote>(data['data']);
    }
    if (dataClassName == 'MessengerInvalidProfileInputException') {
      return deserialize<_i54.MessengerInvalidProfileInputException>(
        data['data'],
      );
    }
    if (dataClassName == 'Profile') {
      return deserialize<_i55.Profile>(data['data']);
    }
    if (dataClassName == 'ContactSearchRelation') {
      return deserialize<_i56.ContactSearchRelation>(data['data']);
    }
    if (dataClassName == 'ContactSearchResult') {
      return deserialize<_i57.ContactSearchResult>(data['data']);
    }
    if (dataClassName == 'MessengerAccountRequiredException') {
      return deserialize<_i58.MessengerAccountRequiredException>(data['data']);
    }
    if (dataClassName == 'MessengerInvalidRegistrationInputException') {
      return deserialize<_i59.MessengerInvalidRegistrationInputException>(
        data['data'],
      );
    }
    if (dataClassName == 'MessengerInvalidUsernameException') {
      return deserialize<_i60.MessengerInvalidUsernameException>(data['data']);
    }
    if (dataClassName == 'MessengerRegistrationIncompleteException') {
      return deserialize<_i61.MessengerRegistrationIncompleteException>(
        data['data'],
      );
    }
    if (dataClassName == 'MessengerRegistrationRequest') {
      return deserialize<_i62.MessengerRegistrationRequest>(data['data']);
    }
    if (dataClassName == 'MessengerUser') {
      return deserialize<_i63.MessengerUser>(data['data']);
    }
    if (dataClassName == 'MessengerUserAlreadyExistsException') {
      return deserialize<_i64.MessengerUserAlreadyExistsException>(
        data['data'],
      );
    }
    if (dataClassName == 'MessengerUserNotFoundException') {
      return deserialize<_i65.MessengerUserNotFoundException>(data['data']);
    }
    if (dataClassName == 'MessengerUsernameTakenException') {
      return deserialize<_i66.MessengerUsernameTakenException>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i3.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i4.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i4.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i5.Chat:
        return _i5.Chat.t;
      case _i6.ChatInvitation:
        return _i6.ChatInvitation.t;
      case _i10.ChatParticipant:
        return _i10.ChatParticipant.t;
      case _i25.Device:
        return _i25.Device.t;
      case _i31.Media:
        return _i31.Media.t;
      case _i38.Message:
        return _i38.Message.t;
      case _i40.MessageReaction:
        return _i40.MessageReaction.t;
      case _i42.MessageReceipt:
        return _i42.MessageReceipt.t;
      case _i49.Poll:
        return _i49.Poll.t;
      case _i50.PollOption:
        return _i50.PollOption.t;
      case _i53.PollVote:
        return _i53.PollVote.t;
      case _i55.Profile:
        return _i55.Profile.t;
      case _i62.MessengerRegistrationRequest:
        return _i62.MessengerRegistrationRequest.t;
      case _i63.MessengerUser:
        return _i63.MessengerUser.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'messenger';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i3.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i4.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
