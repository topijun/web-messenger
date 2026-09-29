import 'package:messenger_client/messenger_client.dart';

/// Maps message protocol failures to copy that is safe to show in the UI.
class MessageErrorMapper {
  /// Maps a send, history, or receipt failure.
  static String map(Object error) {
    if (error is MessengerInvalidMediaException) {
      return error.message;
    }
    if (error is MessengerMediaNotFoundException) {
      return 'That media could not be found.';
    }
    if (error is MessengerInvalidChatInputException) {
      return error.message;
    }
    if (error is MessengerEncryptedDataException) {
      return error.message;
    }
    if (error is MessengerNotChatMemberException) {
      return 'You are not a member of this chat.';
    }
    if (error is MessengerChatNotFoundException) {
      return 'That chat could not be found.';
    }
    if (error is MessengerNotMessageOwnerException) {
      return 'You can only change your own messages.';
    }
    if (error is MessengerMessageNotFoundException) {
      return 'That message could not be found.';
    }
    if (error is MessengerNotMessageRecipientException) {
      return 'You cannot update receipts for your own message.';
    }
    if (error is ServerpodClientException) {
      return 'A connection error occurred. Please check your internet '
          'connection and try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
