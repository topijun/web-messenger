import 'package:messenger_server/src/email/auth_email_sender.dart';
import 'package:messenger_server/src/email/smtp_auth_email_sender.dart';
import 'package:test/test.dart';

void main() {
  const fakeSmtpSecret = 'test-smtp-secret-value';

  test(
    'fromPasswords uses Gmail defaults and omits the password from toString',
    () {
      final sender = SmtpAuthEmailSender.fromPasswords({
        'smtpUsername': 'tictactoe.admin@gmail.com',
        'smtpPassword': fakeSmtpSecret,
      });

      expect(sender.host, 'smtp.gmail.com');
      expect(sender.port, 587);
      expect(sender.username, 'tictactoe.admin@gmail.com');
      expect(sender.from, 'tictactoe.admin@gmail.com');
      expect(sender.toString(), contains('smtp.gmail.com'));
      expect(sender.toString(), isNot(contains(fakeSmtpSecret)));
      expect(sender.toString(), isNot(contains('smtpPassword')));
    },
  );

  test('send without a password fails without exposing a secret', () async {
    final sender = SmtpAuthEmailSender.fromPasswords({
      'smtpUsername': 'tictactoe.admin@gmail.com',
      'smtpPassword': '',
    });

    try {
      await sender.send(
        const AuthEmailMessage(
          recipient: 'reader@example.com',
          subject: 'test',
          body: 'body',
        ),
      );
      fail('expected AuthEmailDeliveryException');
    } on AuthEmailDeliveryException catch (error) {
      expect(error.toString(), contains('SMTP is not configured'));
      expect(error.toString(), isNot(contains(fakeSmtpSecret)));
      expect(error.toString(), isNot(contains('smtpPassword')));
    }
  });

  test('delivery exception text never includes the configured password', () {
    final sender = SmtpAuthEmailSender.fromPasswords({
      'smtpHost': 'smtp.gmail.com',
      'smtpPort': '587',
      'smtpUsername': 'tictactoe.admin@gmail.com',
      'smtpPassword': fakeSmtpSecret,
      'smtpFrom': 'tictactoe.admin@gmail.com',
    });

    expect(sender.toString(), isNot(contains(fakeSmtpSecret)));
    expect(
      const AuthEmailDeliveryException().toString(),
      isNot(contains(fakeSmtpSecret)),
    );
  });
}
