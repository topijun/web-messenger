import 'package:messenger_server/src/email/auth_email_service.dart';
import 'package:test/test.dart';

import 'fake_auth_email_sender.dart';

void main() {
  test('registration email uses the recipient and includes the code', () async {
    final sender = FakeAuthEmailSender();
    final emails = AuthEmailService(sender);

    await emails.sendRegistrationVerification(
      email: 'reader@example.com',
      verificationCode: 'verify01',
    );

    expect(sender.sent, hasLength(1));
    final message = sender.sent.single;
    expect(message.recipient, 'reader@example.com');
    expect(message.subject, contains('verification code'));
    expect(message.body, contains('verify01'));
    expect(message.body, contains('Messenger account verification code'));
    expect(message.body, contains('Enter this code in the Messenger app'));
    expect(message.body, isNot(contains('authUserId')));
    expect(message.body, isNot(contains('accountRequestId')));
  });

  test(
    'password reset email uses the recipient and includes the code',
    () async {
      final sender = FakeAuthEmailSender();
      final emails = AuthEmailService(sender);

      await emails.sendPasswordReset(
        email: 'reader@example.com',
        verificationCode: 'reset001',
      );

      expect(sender.sent, hasLength(1));
      final message = sender.sent.single;
      expect(message.recipient, 'reader@example.com');
      expect(message.subject, contains('password reset'));
      expect(message.body, contains('reset001'));
      expect(message.body, contains('Messenger password reset code'));
      expect(message.body, contains('Enter this code in the Messenger app'));
      expect(message.body, isNot(contains('passwordResetRequestId')));
      expect(message.body, isNot(contains('finishPasswordResetToken')));
    },
  );

  test(
    'email bodies do not include SMTP configuration keys or secrets',
    () async {
      final sender = FakeAuthEmailSender();
      final emails = AuthEmailService(sender);

      await emails.sendRegistrationVerification(
        email: 'reader@example.com',
        verificationCode: 'verify01',
      );
      await emails.sendPasswordReset(
        email: 'reader@example.com',
        verificationCode: 'reset001',
      );

      for (final message in sender.sent) {
        expect(message.body, isNot(contains('smtpPassword')));
        expect(message.body, isNot(contains('SERVERPOD_PASSWORD')));
        expect(message.subject, isNot(contains('smtpPassword')));
      }
    },
  );
}
