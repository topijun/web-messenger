import 'package:messenger_server/src/email/auth_email_sender.dart';

/// In-memory [AuthEmailSender] for tests. Never talks to SMTP.
class FakeAuthEmailSender implements AuthEmailSender {
  /// Messages accepted by [send].
  final sent = <AuthEmailMessage>[];

  /// When set, [send] throws this and does not record the message.
  Object? errorToThrow;

  @override
  Future<void> send(AuthEmailMessage message) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    sent.add(message);
  }
}
