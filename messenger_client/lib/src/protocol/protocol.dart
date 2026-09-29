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

import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'chats/chat.dart' as _i2;
import 'chats/chat_invitation.dart' as _i3;
import 'chats/chat_invitation_status.dart' as _i4;
import 'chats/chat_invitation_view.dart' as _i5;
import 'chats/chat_member.dart' as _i6;
import 'chats/chat_participant.dart' as _i7;
import 'chats/chat_participant_role.dart' as _i8;
import 'chats/chat_summary.dart' as _i9;
import 'chats/chat_type.dart' as _i10;
import 'chats/messenger_already_chat_participant_exception.dart' as _i11;
import 'chats/messenger_chat_not_found_exception.dart' as _i12;
import 'chats/messenger_direct_chat_already_exists_exception.dart' as _i13;
import 'chats/messenger_duplicate_invitation_exception.dart' as _i14;
import 'chats/messenger_invalid_chat_input_exception.dart' as _i15;
import 'chats/messenger_invitation_already_handled_exception.dart' as _i16;
import 'chats/messenger_invitation_not_found_exception.dart' as _i17;
import 'chats/messenger_not_chat_admin_exception.dart' as _i18;
import 'chats/messenger_not_chat_member_exception.dart' as _i19;
import 'chats/messenger_self_invitation_exception.dart' as _i20;
import 'chats/user_avatar_ref.dart' as _i21;
import 'devices/device.dart' as _i22;
import 'devices/device_platform.dart' as _i23;
import 'devices/messenger_device_not_found_exception.dart' as _i24;
import 'encryption/messenger_encrypted_data_exception.dart' as _i25;
import 'greetings/greeting.dart' as _i26;
import 'media/chat_media.dart' as _i27;
import 'media/media.dart' as _i28;
import 'media/media_type.dart' as _i29;
import 'media/messenger_invalid_media_exception.dart' as _i30;
import 'media/messenger_media_not_found_exception.dart' as _i31;
import 'media/profile_image.dart' as _i32;
import 'messages/chat_event.dart' as _i33;
import 'messages/chat_event_kind.dart' as _i34;
import 'messages/message.dart' as _i35;
import 'messages/message_history_page.dart' as _i36;
import 'messages/message_receipt.dart' as _i37;
import 'messages/message_type.dart' as _i38;
import 'messages/message_view.dart' as _i39;
import 'messages/messenger_message_not_found_exception.dart' as _i40;
import 'messages/messenger_not_message_owner_exception.dart' as _i41;
import 'messages/messenger_not_message_recipient_exception.dart' as _i42;
import 'messages/messenger_poll_not_found_exception.dart' as _i43;
import 'messages/poll.dart' as _i44;
import 'messages/poll_option.dart' as _i45;
import 'messages/poll_option_view.dart' as _i46;
import 'messages/poll_view.dart' as _i47;
import 'messages/poll_vote.dart' as _i48;
import 'profiles/messenger_invalid_profile_input_exception.dart' as _i49;
import 'profiles/profile.dart' as _i50;
import 'users/contact_search_relation.dart' as _i51;
import 'users/contact_search_result.dart' as _i52;
import 'users/messenger_account_required_exception.dart' as _i53;
import 'users/messenger_invalid_registration_input_exception.dart' as _i54;
import 'users/messenger_invalid_username_exception.dart' as _i55;
import 'users/messenger_registration_incomplete_exception.dart' as _i56;
import 'users/messenger_user.dart' as _i57;
import 'users/messenger_user_already_exists_exception.dart' as _i58;
import 'users/messenger_user_not_found_exception.dart' as _i59;
import 'users/messenger_username_taken_exception.dart' as _i60;
import 'package:messenger_client/src/protocol/chats/chat_summary.dart' as _i61;
import 'package:messenger_client/src/protocol/chats/chat_member.dart' as _i62;
import 'package:messenger_client/src/protocol/chats/chat_invitation_view.dart'
    as _i63;
import 'package:messenger_client/src/protocol/devices/device.dart' as _i64;
import 'package:messenger_client/src/protocol/messages/message_view.dart'
    as _i65;
import 'package:messenger_client/src/protocol/messages/message_receipt.dart'
    as _i66;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i67;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i68;
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
export 'users/messenger_user.dart';
export 'users/messenger_user_already_exists_exception.dart';
export 'users/messenger_user_not_found_exception.dart';
export 'users/messenger_username_taken_exception.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

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

    if (t == _i2.Chat) {
      return _i2.Chat.fromJson(data) as T;
    }
    if (t == _i3.ChatInvitation) {
      return _i3.ChatInvitation.fromJson(data) as T;
    }
    if (t == _i4.ChatInvitationStatus) {
      return _i4.ChatInvitationStatus.fromJson(data) as T;
    }
    if (t == _i5.ChatInvitationView) {
      return _i5.ChatInvitationView.fromJson(data) as T;
    }
    if (t == _i6.ChatMember) {
      return _i6.ChatMember.fromJson(data) as T;
    }
    if (t == _i7.ChatParticipant) {
      return _i7.ChatParticipant.fromJson(data) as T;
    }
    if (t == _i8.ChatParticipantRole) {
      return _i8.ChatParticipantRole.fromJson(data) as T;
    }
    if (t == _i9.ChatSummary) {
      return _i9.ChatSummary.fromJson(data) as T;
    }
    if (t == _i10.ChatType) {
      return _i10.ChatType.fromJson(data) as T;
    }
    if (t == _i11.MessengerAlreadyChatParticipantException) {
      return _i11.MessengerAlreadyChatParticipantException.fromJson(data) as T;
    }
    if (t == _i12.MessengerChatNotFoundException) {
      return _i12.MessengerChatNotFoundException.fromJson(data) as T;
    }
    if (t == _i13.MessengerDirectChatAlreadyExistsException) {
      return _i13.MessengerDirectChatAlreadyExistsException.fromJson(data) as T;
    }
    if (t == _i14.MessengerDuplicateInvitationException) {
      return _i14.MessengerDuplicateInvitationException.fromJson(data) as T;
    }
    if (t == _i15.MessengerInvalidChatInputException) {
      return _i15.MessengerInvalidChatInputException.fromJson(data) as T;
    }
    if (t == _i16.MessengerInvitationAlreadyHandledException) {
      return _i16.MessengerInvitationAlreadyHandledException.fromJson(data)
          as T;
    }
    if (t == _i17.MessengerInvitationNotFoundException) {
      return _i17.MessengerInvitationNotFoundException.fromJson(data) as T;
    }
    if (t == _i18.MessengerNotChatAdminException) {
      return _i18.MessengerNotChatAdminException.fromJson(data) as T;
    }
    if (t == _i19.MessengerNotChatMemberException) {
      return _i19.MessengerNotChatMemberException.fromJson(data) as T;
    }
    if (t == _i20.MessengerSelfInvitationException) {
      return _i20.MessengerSelfInvitationException.fromJson(data) as T;
    }
    if (t == _i21.UserAvatarRef) {
      return _i21.UserAvatarRef.fromJson(data) as T;
    }
    if (t == _i22.Device) {
      return _i22.Device.fromJson(data) as T;
    }
    if (t == _i23.DevicePlatform) {
      return _i23.DevicePlatform.fromJson(data) as T;
    }
    if (t == _i24.MessengerDeviceNotFoundException) {
      return _i24.MessengerDeviceNotFoundException.fromJson(data) as T;
    }
    if (t == _i25.MessengerEncryptedDataException) {
      return _i25.MessengerEncryptedDataException.fromJson(data) as T;
    }
    if (t == _i26.Greeting) {
      return _i26.Greeting.fromJson(data) as T;
    }
    if (t == _i27.ChatMedia) {
      return _i27.ChatMedia.fromJson(data) as T;
    }
    if (t == _i28.Media) {
      return _i28.Media.fromJson(data) as T;
    }
    if (t == _i29.MediaType) {
      return _i29.MediaType.fromJson(data) as T;
    }
    if (t == _i30.MessengerInvalidMediaException) {
      return _i30.MessengerInvalidMediaException.fromJson(data) as T;
    }
    if (t == _i31.MessengerMediaNotFoundException) {
      return _i31.MessengerMediaNotFoundException.fromJson(data) as T;
    }
    if (t == _i32.ProfileImage) {
      return _i32.ProfileImage.fromJson(data) as T;
    }
    if (t == _i33.ChatEvent) {
      return _i33.ChatEvent.fromJson(data) as T;
    }
    if (t == _i34.ChatEventKind) {
      return _i34.ChatEventKind.fromJson(data) as T;
    }
    if (t == _i35.Message) {
      return _i35.Message.fromJson(data) as T;
    }
    if (t == _i36.MessageHistoryPage) {
      return _i36.MessageHistoryPage.fromJson(data) as T;
    }
    if (t == _i37.MessageReceipt) {
      return _i37.MessageReceipt.fromJson(data) as T;
    }
    if (t == _i38.MessageType) {
      return _i38.MessageType.fromJson(data) as T;
    }
    if (t == _i39.MessageView) {
      return _i39.MessageView.fromJson(data) as T;
    }
    if (t == _i40.MessengerMessageNotFoundException) {
      return _i40.MessengerMessageNotFoundException.fromJson(data) as T;
    }
    if (t == _i41.MessengerNotMessageOwnerException) {
      return _i41.MessengerNotMessageOwnerException.fromJson(data) as T;
    }
    if (t == _i42.MessengerNotMessageRecipientException) {
      return _i42.MessengerNotMessageRecipientException.fromJson(data) as T;
    }
    if (t == _i43.MessengerPollNotFoundException) {
      return _i43.MessengerPollNotFoundException.fromJson(data) as T;
    }
    if (t == _i44.Poll) {
      return _i44.Poll.fromJson(data) as T;
    }
    if (t == _i45.PollOption) {
      return _i45.PollOption.fromJson(data) as T;
    }
    if (t == _i46.PollOptionView) {
      return _i46.PollOptionView.fromJson(data) as T;
    }
    if (t == _i47.PollView) {
      return _i47.PollView.fromJson(data) as T;
    }
    if (t == _i48.PollVote) {
      return _i48.PollVote.fromJson(data) as T;
    }
    if (t == _i49.MessengerInvalidProfileInputException) {
      return _i49.MessengerInvalidProfileInputException.fromJson(data) as T;
    }
    if (t == _i50.Profile) {
      return _i50.Profile.fromJson(data) as T;
    }
    if (t == _i51.ContactSearchRelation) {
      return _i51.ContactSearchRelation.fromJson(data) as T;
    }
    if (t == _i52.ContactSearchResult) {
      return _i52.ContactSearchResult.fromJson(data) as T;
    }
    if (t == _i53.MessengerAccountRequiredException) {
      return _i53.MessengerAccountRequiredException.fromJson(data) as T;
    }
    if (t == _i54.MessengerInvalidRegistrationInputException) {
      return _i54.MessengerInvalidRegistrationInputException.fromJson(data)
          as T;
    }
    if (t == _i55.MessengerInvalidUsernameException) {
      return _i55.MessengerInvalidUsernameException.fromJson(data) as T;
    }
    if (t == _i56.MessengerRegistrationIncompleteException) {
      return _i56.MessengerRegistrationIncompleteException.fromJson(data) as T;
    }
    if (t == _i57.MessengerUser) {
      return _i57.MessengerUser.fromJson(data) as T;
    }
    if (t == _i58.MessengerUserAlreadyExistsException) {
      return _i58.MessengerUserAlreadyExistsException.fromJson(data) as T;
    }
    if (t == _i59.MessengerUserNotFoundException) {
      return _i59.MessengerUserNotFoundException.fromJson(data) as T;
    }
    if (t == _i60.MessengerUsernameTakenException) {
      return _i60.MessengerUsernameTakenException.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Chat?>()) {
      return (data != null ? _i2.Chat.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.ChatInvitation?>()) {
      return (data != null ? _i3.ChatInvitation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.ChatInvitationStatus?>()) {
      return (data != null ? _i4.ChatInvitationStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i5.ChatInvitationView?>()) {
      return (data != null ? _i5.ChatInvitationView.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.ChatMember?>()) {
      return (data != null ? _i6.ChatMember.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.ChatParticipant?>()) {
      return (data != null ? _i7.ChatParticipant.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.ChatParticipantRole?>()) {
      return (data != null ? _i8.ChatParticipantRole.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i9.ChatSummary?>()) {
      return (data != null ? _i9.ChatSummary.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.ChatType?>()) {
      return (data != null ? _i10.ChatType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.MessengerAlreadyChatParticipantException?>()) {
      return (data != null
              ? _i11.MessengerAlreadyChatParticipantException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i12.MessengerChatNotFoundException?>()) {
      return (data != null
              ? _i12.MessengerChatNotFoundException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i13.MessengerDirectChatAlreadyExistsException?>()) {
      return (data != null
              ? _i13.MessengerDirectChatAlreadyExistsException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i14.MessengerDuplicateInvitationException?>()) {
      return (data != null
              ? _i14.MessengerDuplicateInvitationException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i15.MessengerInvalidChatInputException?>()) {
      return (data != null
              ? _i15.MessengerInvalidChatInputException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i16.MessengerInvitationAlreadyHandledException?>()) {
      return (data != null
              ? _i16.MessengerInvitationAlreadyHandledException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i17.MessengerInvitationNotFoundException?>()) {
      return (data != null
              ? _i17.MessengerInvitationNotFoundException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i18.MessengerNotChatAdminException?>()) {
      return (data != null
              ? _i18.MessengerNotChatAdminException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i19.MessengerNotChatMemberException?>()) {
      return (data != null
              ? _i19.MessengerNotChatMemberException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i20.MessengerSelfInvitationException?>()) {
      return (data != null
              ? _i20.MessengerSelfInvitationException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i21.UserAvatarRef?>()) {
      return (data != null ? _i21.UserAvatarRef.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.Device?>()) {
      return (data != null ? _i22.Device.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.DevicePlatform?>()) {
      return (data != null ? _i23.DevicePlatform.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.MessengerDeviceNotFoundException?>()) {
      return (data != null
              ? _i24.MessengerDeviceNotFoundException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i25.MessengerEncryptedDataException?>()) {
      return (data != null
              ? _i25.MessengerEncryptedDataException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i26.Greeting?>()) {
      return (data != null ? _i26.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.ChatMedia?>()) {
      return (data != null ? _i27.ChatMedia.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i28.Media?>()) {
      return (data != null ? _i28.Media.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i29.MediaType?>()) {
      return (data != null ? _i29.MediaType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i30.MessengerInvalidMediaException?>()) {
      return (data != null
              ? _i30.MessengerInvalidMediaException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i31.MessengerMediaNotFoundException?>()) {
      return (data != null
              ? _i31.MessengerMediaNotFoundException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i32.ProfileImage?>()) {
      return (data != null ? _i32.ProfileImage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.ChatEvent?>()) {
      return (data != null ? _i33.ChatEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.ChatEventKind?>()) {
      return (data != null ? _i34.ChatEventKind.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i35.Message?>()) {
      return (data != null ? _i35.Message.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.MessageHistoryPage?>()) {
      return (data != null ? _i36.MessageHistoryPage.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i37.MessageReceipt?>()) {
      return (data != null ? _i37.MessageReceipt.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.MessageType?>()) {
      return (data != null ? _i38.MessageType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i39.MessageView?>()) {
      return (data != null ? _i39.MessageView.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i40.MessengerMessageNotFoundException?>()) {
      return (data != null
              ? _i40.MessengerMessageNotFoundException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i41.MessengerNotMessageOwnerException?>()) {
      return (data != null
              ? _i41.MessengerNotMessageOwnerException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i42.MessengerNotMessageRecipientException?>()) {
      return (data != null
              ? _i42.MessengerNotMessageRecipientException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i43.MessengerPollNotFoundException?>()) {
      return (data != null
              ? _i43.MessengerPollNotFoundException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i44.Poll?>()) {
      return (data != null ? _i44.Poll.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i45.PollOption?>()) {
      return (data != null ? _i45.PollOption.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i46.PollOptionView?>()) {
      return (data != null ? _i46.PollOptionView.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i47.PollView?>()) {
      return (data != null ? _i47.PollView.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i48.PollVote?>()) {
      return (data != null ? _i48.PollVote.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i49.MessengerInvalidProfileInputException?>()) {
      return (data != null
              ? _i49.MessengerInvalidProfileInputException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i50.Profile?>()) {
      return (data != null ? _i50.Profile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i51.ContactSearchRelation?>()) {
      return (data != null ? _i51.ContactSearchRelation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i52.ContactSearchResult?>()) {
      return (data != null ? _i52.ContactSearchResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i53.MessengerAccountRequiredException?>()) {
      return (data != null
              ? _i53.MessengerAccountRequiredException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i54.MessengerInvalidRegistrationInputException?>()) {
      return (data != null
              ? _i54.MessengerInvalidRegistrationInputException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i55.MessengerInvalidUsernameException?>()) {
      return (data != null
              ? _i55.MessengerInvalidUsernameException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i56.MessengerRegistrationIncompleteException?>()) {
      return (data != null
              ? _i56.MessengerRegistrationIncompleteException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i57.MessengerUser?>()) {
      return (data != null ? _i57.MessengerUser.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i58.MessengerUserAlreadyExistsException?>()) {
      return (data != null
              ? _i58.MessengerUserAlreadyExistsException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i59.MessengerUserNotFoundException?>()) {
      return (data != null
              ? _i59.MessengerUserNotFoundException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i60.MessengerUsernameTakenException?>()) {
      return (data != null
              ? _i60.MessengerUsernameTakenException.fromJson(data)
              : null)
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i21.UserAvatarRef>) {
      return (data as List)
              .map((e) => deserialize<_i21.UserAvatarRef>(e))
              .toList()
          as T;
    }
    if (t == List<_i37.MessageReceipt>) {
      return (data as List)
              .map((e) => deserialize<_i37.MessageReceipt>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i37.MessageReceipt>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i37.MessageReceipt>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i39.MessageView>) {
      return (data as List)
              .map((e) => deserialize<_i39.MessageView>(e))
              .toList()
          as T;
    }
    if (t == List<_i46.PollOptionView>) {
      return (data as List)
              .map((e) => deserialize<_i46.PollOptionView>(e))
              .toList()
          as T;
    }
    if (t == List<_i3.ChatInvitation>) {
      return (data as List)
              .map((e) => deserialize<_i3.ChatInvitation>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i3.ChatInvitation>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i3.ChatInvitation>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i61.ChatSummary>) {
      return (data as List)
              .map((e) => deserialize<_i61.ChatSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_i62.ChatMember>) {
      return (data as List).map((e) => deserialize<_i62.ChatMember>(e)).toList()
          as T;
    }
    if (t == List<_i63.ChatInvitationView>) {
      return (data as List)
              .map((e) => deserialize<_i63.ChatInvitationView>(e))
              .toList()
          as T;
    }
    if (t == List<_i64.Device>) {
      return (data as List).map((e) => deserialize<_i64.Device>(e)).toList()
          as T;
    }
    if (t == List<_i65.MessageView>) {
      return (data as List)
              .map((e) => deserialize<_i65.MessageView>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i66.MessageReceipt>) {
      return (data as List)
              .map((e) => deserialize<_i66.MessageReceipt>(e))
              .toList()
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    try {
      return _i67.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i68.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.Chat => 'Chat',
      _i3.ChatInvitation => 'ChatInvitation',
      _i4.ChatInvitationStatus => 'ChatInvitationStatus',
      _i5.ChatInvitationView => 'ChatInvitationView',
      _i6.ChatMember => 'ChatMember',
      _i7.ChatParticipant => 'ChatParticipant',
      _i8.ChatParticipantRole => 'ChatParticipantRole',
      _i9.ChatSummary => 'ChatSummary',
      _i10.ChatType => 'ChatType',
      _i11.MessengerAlreadyChatParticipantException =>
        'MessengerAlreadyChatParticipantException',
      _i12.MessengerChatNotFoundException => 'MessengerChatNotFoundException',
      _i13.MessengerDirectChatAlreadyExistsException =>
        'MessengerDirectChatAlreadyExistsException',
      _i14.MessengerDuplicateInvitationException =>
        'MessengerDuplicateInvitationException',
      _i15.MessengerInvalidChatInputException =>
        'MessengerInvalidChatInputException',
      _i16.MessengerInvitationAlreadyHandledException =>
        'MessengerInvitationAlreadyHandledException',
      _i17.MessengerInvitationNotFoundException =>
        'MessengerInvitationNotFoundException',
      _i18.MessengerNotChatAdminException => 'MessengerNotChatAdminException',
      _i19.MessengerNotChatMemberException => 'MessengerNotChatMemberException',
      _i20.MessengerSelfInvitationException =>
        'MessengerSelfInvitationException',
      _i21.UserAvatarRef => 'UserAvatarRef',
      _i22.Device => 'Device',
      _i23.DevicePlatform => 'DevicePlatform',
      _i24.MessengerDeviceNotFoundException =>
        'MessengerDeviceNotFoundException',
      _i25.MessengerEncryptedDataException => 'MessengerEncryptedDataException',
      _i26.Greeting => 'Greeting',
      _i27.ChatMedia => 'ChatMedia',
      _i28.Media => 'Media',
      _i29.MediaType => 'MediaType',
      _i30.MessengerInvalidMediaException => 'MessengerInvalidMediaException',
      _i31.MessengerMediaNotFoundException => 'MessengerMediaNotFoundException',
      _i32.ProfileImage => 'ProfileImage',
      _i33.ChatEvent => 'ChatEvent',
      _i34.ChatEventKind => 'ChatEventKind',
      _i35.Message => 'Message',
      _i36.MessageHistoryPage => 'MessageHistoryPage',
      _i37.MessageReceipt => 'MessageReceipt',
      _i38.MessageType => 'MessageType',
      _i39.MessageView => 'MessageView',
      _i40.MessengerMessageNotFoundException =>
        'MessengerMessageNotFoundException',
      _i41.MessengerNotMessageOwnerException =>
        'MessengerNotMessageOwnerException',
      _i42.MessengerNotMessageRecipientException =>
        'MessengerNotMessageRecipientException',
      _i43.MessengerPollNotFoundException => 'MessengerPollNotFoundException',
      _i44.Poll => 'Poll',
      _i45.PollOption => 'PollOption',
      _i46.PollOptionView => 'PollOptionView',
      _i47.PollView => 'PollView',
      _i48.PollVote => 'PollVote',
      _i49.MessengerInvalidProfileInputException =>
        'MessengerInvalidProfileInputException',
      _i50.Profile => 'Profile',
      _i51.ContactSearchRelation => 'ContactSearchRelation',
      _i52.ContactSearchResult => 'ContactSearchResult',
      _i53.MessengerAccountRequiredException =>
        'MessengerAccountRequiredException',
      _i54.MessengerInvalidRegistrationInputException =>
        'MessengerInvalidRegistrationInputException',
      _i55.MessengerInvalidUsernameException =>
        'MessengerInvalidUsernameException',
      _i56.MessengerRegistrationIncompleteException =>
        'MessengerRegistrationIncompleteException',
      _i57.MessengerUser => 'MessengerUser',
      _i58.MessengerUserAlreadyExistsException =>
        'MessengerUserAlreadyExistsException',
      _i59.MessengerUserNotFoundException => 'MessengerUserNotFoundException',
      _i60.MessengerUsernameTakenException => 'MessengerUsernameTakenException',
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
      case _i2.Chat():
        return 'Chat';
      case _i3.ChatInvitation():
        return 'ChatInvitation';
      case _i4.ChatInvitationStatus():
        return 'ChatInvitationStatus';
      case _i5.ChatInvitationView():
        return 'ChatInvitationView';
      case _i6.ChatMember():
        return 'ChatMember';
      case _i7.ChatParticipant():
        return 'ChatParticipant';
      case _i8.ChatParticipantRole():
        return 'ChatParticipantRole';
      case _i9.ChatSummary():
        return 'ChatSummary';
      case _i10.ChatType():
        return 'ChatType';
      case _i11.MessengerAlreadyChatParticipantException():
        return 'MessengerAlreadyChatParticipantException';
      case _i12.MessengerChatNotFoundException():
        return 'MessengerChatNotFoundException';
      case _i13.MessengerDirectChatAlreadyExistsException():
        return 'MessengerDirectChatAlreadyExistsException';
      case _i14.MessengerDuplicateInvitationException():
        return 'MessengerDuplicateInvitationException';
      case _i15.MessengerInvalidChatInputException():
        return 'MessengerInvalidChatInputException';
      case _i16.MessengerInvitationAlreadyHandledException():
        return 'MessengerInvitationAlreadyHandledException';
      case _i17.MessengerInvitationNotFoundException():
        return 'MessengerInvitationNotFoundException';
      case _i18.MessengerNotChatAdminException():
        return 'MessengerNotChatAdminException';
      case _i19.MessengerNotChatMemberException():
        return 'MessengerNotChatMemberException';
      case _i20.MessengerSelfInvitationException():
        return 'MessengerSelfInvitationException';
      case _i21.UserAvatarRef():
        return 'UserAvatarRef';
      case _i22.Device():
        return 'Device';
      case _i23.DevicePlatform():
        return 'DevicePlatform';
      case _i24.MessengerDeviceNotFoundException():
        return 'MessengerDeviceNotFoundException';
      case _i25.MessengerEncryptedDataException():
        return 'MessengerEncryptedDataException';
      case _i26.Greeting():
        return 'Greeting';
      case _i27.ChatMedia():
        return 'ChatMedia';
      case _i28.Media():
        return 'Media';
      case _i29.MediaType():
        return 'MediaType';
      case _i30.MessengerInvalidMediaException():
        return 'MessengerInvalidMediaException';
      case _i31.MessengerMediaNotFoundException():
        return 'MessengerMediaNotFoundException';
      case _i32.ProfileImage():
        return 'ProfileImage';
      case _i33.ChatEvent():
        return 'ChatEvent';
      case _i34.ChatEventKind():
        return 'ChatEventKind';
      case _i35.Message():
        return 'Message';
      case _i36.MessageHistoryPage():
        return 'MessageHistoryPage';
      case _i37.MessageReceipt():
        return 'MessageReceipt';
      case _i38.MessageType():
        return 'MessageType';
      case _i39.MessageView():
        return 'MessageView';
      case _i40.MessengerMessageNotFoundException():
        return 'MessengerMessageNotFoundException';
      case _i41.MessengerNotMessageOwnerException():
        return 'MessengerNotMessageOwnerException';
      case _i42.MessengerNotMessageRecipientException():
        return 'MessengerNotMessageRecipientException';
      case _i43.MessengerPollNotFoundException():
        return 'MessengerPollNotFoundException';
      case _i44.Poll():
        return 'Poll';
      case _i45.PollOption():
        return 'PollOption';
      case _i46.PollOptionView():
        return 'PollOptionView';
      case _i47.PollView():
        return 'PollView';
      case _i48.PollVote():
        return 'PollVote';
      case _i49.MessengerInvalidProfileInputException():
        return 'MessengerInvalidProfileInputException';
      case _i50.Profile():
        return 'Profile';
      case _i51.ContactSearchRelation():
        return 'ContactSearchRelation';
      case _i52.ContactSearchResult():
        return 'ContactSearchResult';
      case _i53.MessengerAccountRequiredException():
        return 'MessengerAccountRequiredException';
      case _i54.MessengerInvalidRegistrationInputException():
        return 'MessengerInvalidRegistrationInputException';
      case _i55.MessengerInvalidUsernameException():
        return 'MessengerInvalidUsernameException';
      case _i56.MessengerRegistrationIncompleteException():
        return 'MessengerRegistrationIncompleteException';
      case _i57.MessengerUser():
        return 'MessengerUser';
      case _i58.MessengerUserAlreadyExistsException():
        return 'MessengerUserAlreadyExistsException';
      case _i59.MessengerUserNotFoundException():
        return 'MessengerUserNotFoundException';
      case _i60.MessengerUsernameTakenException():
        return 'MessengerUsernameTakenException';
    }
    className = _i67.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i68.Protocol().getClassNameForObject(data);
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
      return deserialize<_i2.Chat>(data['data']);
    }
    if (dataClassName == 'ChatInvitation') {
      return deserialize<_i3.ChatInvitation>(data['data']);
    }
    if (dataClassName == 'ChatInvitationStatus') {
      return deserialize<_i4.ChatInvitationStatus>(data['data']);
    }
    if (dataClassName == 'ChatInvitationView') {
      return deserialize<_i5.ChatInvitationView>(data['data']);
    }
    if (dataClassName == 'ChatMember') {
      return deserialize<_i6.ChatMember>(data['data']);
    }
    if (dataClassName == 'ChatParticipant') {
      return deserialize<_i7.ChatParticipant>(data['data']);
    }
    if (dataClassName == 'ChatParticipantRole') {
      return deserialize<_i8.ChatParticipantRole>(data['data']);
    }
    if (dataClassName == 'ChatSummary') {
      return deserialize<_i9.ChatSummary>(data['data']);
    }
    if (dataClassName == 'ChatType') {
      return deserialize<_i10.ChatType>(data['data']);
    }
    if (dataClassName == 'MessengerAlreadyChatParticipantException') {
      return deserialize<_i11.MessengerAlreadyChatParticipantException>(
        data['data'],
      );
    }
    if (dataClassName == 'MessengerChatNotFoundException') {
      return deserialize<_i12.MessengerChatNotFoundException>(data['data']);
    }
    if (dataClassName == 'MessengerDirectChatAlreadyExistsException') {
      return deserialize<_i13.MessengerDirectChatAlreadyExistsException>(
        data['data'],
      );
    }
    if (dataClassName == 'MessengerDuplicateInvitationException') {
      return deserialize<_i14.MessengerDuplicateInvitationException>(
        data['data'],
      );
    }
    if (dataClassName == 'MessengerInvalidChatInputException') {
      return deserialize<_i15.MessengerInvalidChatInputException>(data['data']);
    }
    if (dataClassName == 'MessengerInvitationAlreadyHandledException') {
      return deserialize<_i16.MessengerInvitationAlreadyHandledException>(
        data['data'],
      );
    }
    if (dataClassName == 'MessengerInvitationNotFoundException') {
      return deserialize<_i17.MessengerInvitationNotFoundException>(
        data['data'],
      );
    }
    if (dataClassName == 'MessengerNotChatAdminException') {
      return deserialize<_i18.MessengerNotChatAdminException>(data['data']);
    }
    if (dataClassName == 'MessengerNotChatMemberException') {
      return deserialize<_i19.MessengerNotChatMemberException>(data['data']);
    }
    if (dataClassName == 'MessengerSelfInvitationException') {
      return deserialize<_i20.MessengerSelfInvitationException>(data['data']);
    }
    if (dataClassName == 'UserAvatarRef') {
      return deserialize<_i21.UserAvatarRef>(data['data']);
    }
    if (dataClassName == 'Device') {
      return deserialize<_i22.Device>(data['data']);
    }
    if (dataClassName == 'DevicePlatform') {
      return deserialize<_i23.DevicePlatform>(data['data']);
    }
    if (dataClassName == 'MessengerDeviceNotFoundException') {
      return deserialize<_i24.MessengerDeviceNotFoundException>(data['data']);
    }
    if (dataClassName == 'MessengerEncryptedDataException') {
      return deserialize<_i25.MessengerEncryptedDataException>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i26.Greeting>(data['data']);
    }
    if (dataClassName == 'ChatMedia') {
      return deserialize<_i27.ChatMedia>(data['data']);
    }
    if (dataClassName == 'Media') {
      return deserialize<_i28.Media>(data['data']);
    }
    if (dataClassName == 'MediaType') {
      return deserialize<_i29.MediaType>(data['data']);
    }
    if (dataClassName == 'MessengerInvalidMediaException') {
      return deserialize<_i30.MessengerInvalidMediaException>(data['data']);
    }
    if (dataClassName == 'MessengerMediaNotFoundException') {
      return deserialize<_i31.MessengerMediaNotFoundException>(data['data']);
    }
    if (dataClassName == 'ProfileImage') {
      return deserialize<_i32.ProfileImage>(data['data']);
    }
    if (dataClassName == 'ChatEvent') {
      return deserialize<_i33.ChatEvent>(data['data']);
    }
    if (dataClassName == 'ChatEventKind') {
      return deserialize<_i34.ChatEventKind>(data['data']);
    }
    if (dataClassName == 'Message') {
      return deserialize<_i35.Message>(data['data']);
    }
    if (dataClassName == 'MessageHistoryPage') {
      return deserialize<_i36.MessageHistoryPage>(data['data']);
    }
    if (dataClassName == 'MessageReceipt') {
      return deserialize<_i37.MessageReceipt>(data['data']);
    }
    if (dataClassName == 'MessageType') {
      return deserialize<_i38.MessageType>(data['data']);
    }
    if (dataClassName == 'MessageView') {
      return deserialize<_i39.MessageView>(data['data']);
    }
    if (dataClassName == 'MessengerMessageNotFoundException') {
      return deserialize<_i40.MessengerMessageNotFoundException>(data['data']);
    }
    if (dataClassName == 'MessengerNotMessageOwnerException') {
      return deserialize<_i41.MessengerNotMessageOwnerException>(data['data']);
    }
    if (dataClassName == 'MessengerNotMessageRecipientException') {
      return deserialize<_i42.MessengerNotMessageRecipientException>(
        data['data'],
      );
    }
    if (dataClassName == 'MessengerPollNotFoundException') {
      return deserialize<_i43.MessengerPollNotFoundException>(data['data']);
    }
    if (dataClassName == 'Poll') {
      return deserialize<_i44.Poll>(data['data']);
    }
    if (dataClassName == 'PollOption') {
      return deserialize<_i45.PollOption>(data['data']);
    }
    if (dataClassName == 'PollOptionView') {
      return deserialize<_i46.PollOptionView>(data['data']);
    }
    if (dataClassName == 'PollView') {
      return deserialize<_i47.PollView>(data['data']);
    }
    if (dataClassName == 'PollVote') {
      return deserialize<_i48.PollVote>(data['data']);
    }
    if (dataClassName == 'MessengerInvalidProfileInputException') {
      return deserialize<_i49.MessengerInvalidProfileInputException>(
        data['data'],
      );
    }
    if (dataClassName == 'Profile') {
      return deserialize<_i50.Profile>(data['data']);
    }
    if (dataClassName == 'ContactSearchRelation') {
      return deserialize<_i51.ContactSearchRelation>(data['data']);
    }
    if (dataClassName == 'ContactSearchResult') {
      return deserialize<_i52.ContactSearchResult>(data['data']);
    }
    if (dataClassName == 'MessengerAccountRequiredException') {
      return deserialize<_i53.MessengerAccountRequiredException>(data['data']);
    }
    if (dataClassName == 'MessengerInvalidRegistrationInputException') {
      return deserialize<_i54.MessengerInvalidRegistrationInputException>(
        data['data'],
      );
    }
    if (dataClassName == 'MessengerInvalidUsernameException') {
      return deserialize<_i55.MessengerInvalidUsernameException>(data['data']);
    }
    if (dataClassName == 'MessengerRegistrationIncompleteException') {
      return deserialize<_i56.MessengerRegistrationIncompleteException>(
        data['data'],
      );
    }
    if (dataClassName == 'MessengerUser') {
      return deserialize<_i57.MessengerUser>(data['data']);
    }
    if (dataClassName == 'MessengerUserAlreadyExistsException') {
      return deserialize<_i58.MessengerUserAlreadyExistsException>(
        data['data'],
      );
    }
    if (dataClassName == 'MessengerUserNotFoundException') {
      return deserialize<_i59.MessengerUserNotFoundException>(data['data']);
    }
    if (dataClassName == 'MessengerUsernameTakenException') {
      return deserialize<_i60.MessengerUsernameTakenException>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i67.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i68.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

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
      return _i67.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i68.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
