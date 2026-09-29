/// Outgoing authentication email used by Email IDP callbacks.
class AuthEmailMessage {
  /// Creates an [AuthEmailMessage].
  const AuthEmailMessage({
    required this.recipient,
    required this.subject,
    required this.body,
  });

  /// Destination mailbox.
  final String recipient;

  /// Message subject. Must not include secrets or request ids.
  final String subject;

  /// Plain-text body. Includes the verification code only.
  final String body;
}

/// Sends authentication emails. Tests inject a fake; production uses SMTP.
abstract class AuthEmailSender {
  /// Delivers [message]. Throws [AuthEmailDeliveryException] on failure.
  Future<void> send(AuthEmailMessage message);
}

/// Clean failure from the auth email path. Never includes SMTP credentials.
class AuthEmailDeliveryException implements Exception {
  /// Creates an [AuthEmailDeliveryException].
  const AuthEmailDeliveryException([
    this.message = 'Auth email could not be sent.',
  ]);

  /// Client-safe description.
  final String message;

  @override
  String toString() => message;
}
