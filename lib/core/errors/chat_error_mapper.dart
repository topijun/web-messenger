import 'package:messenger_client/messenger_client.dart';

/// Maps chat protocol failures to copy that is safe to show in the UI.
class ChatErrorMapper {
  /// Maps a chat or invitation failure.
  static String map(Object error) {
    if (error is MessengerSelfInvitationException) {
      return 'You cannot invite yourself.';
    }
    if (error is MessengerDuplicateInvitationException) {
      return 'An invitation is already pending with ${error.username}.';
    }
    if (error is MessengerDirectChatAlreadyExistsException) {
      return 'You already have a direct chat with ${error.username}.';
    }
    if (error is MessengerAlreadyChatParticipantException) {
      return '${error.username} is already in this chat.';
    }
    if (error is MessengerUserNotFoundException) {
      return 'No user named ${error.username} was found.';
    }
    if (error is MessengerNotChatAdminException) {
      return 'Only a group admin can invite people.';
    }
    if (error is MessengerEncryptedDataException) {
      return error.message;
    }
    if (error is MessengerNotChatMemberException) {
      return 'You are not a member of this chat.';
    }
    if (error is MessengerInvitationAlreadyHandledException) {
      return 'This invitation has already been handled.';
    }
    if (error is MessengerInvitationNotFoundException) {
      return 'That invitation could not be found.';
    }
    if (error is MessengerChatNotFoundException) {
      return 'That chat could not be found.';
    }
    if (error is MessengerInvalidChatInputException) {
      return error.message;
    }
    if (error is ServerpodClientException) {
      return 'A connection error occurred. Please check your internet '
          'connection and try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
