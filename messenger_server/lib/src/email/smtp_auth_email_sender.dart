import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';
import 'package:serverpod/serverpod.dart';

import 'auth_email_sender.dart';

/// Gmail-compatible SMTP sender. Credentials come from Serverpod passwords.
class SmtpAuthEmailSender implements AuthEmailSender {
  /// Creates an [SmtpAuthEmailSender].
  SmtpAuthEmailSender({
    required this.host,
    required this.port,
    required this.username,
    required String password,
    required this.from,
  }) : _password = password;

  /// SMTP hostname, for example `smtp.gmail.com`.
  final String host;

  /// SMTP port. Gmail STARTTLS uses 587.
  final int port;

  /// SMTP username.
  final String username;

  /// Envelope From address.
  final String from;

  final String _password;

  static const _hostKey = 'smtpHost';
  static const _portKey = 'smtpPort';
  static const _usernameKey = 'smtpUsername';
  static const _passwordKey = 'smtpPassword';
  static const _fromKey = 'smtpFrom';

  /// Loads SMTP settings from Serverpod passwords. Missing secrets do not
  /// crash startup; [send] fails cleanly instead.
  factory SmtpAuthEmailSender.fromServerpod(Serverpod pod) {
    return SmtpAuthEmailSender.fromPasswords({
      _hostKey: pod.getPassword(_hostKey),
      _portKey: pod.getPassword(_portKey),
      _usernameKey: pod.getPassword(_usernameKey),
      _passwordKey: pod.getPassword(_passwordKey),
      _fromKey: pod.getPassword(_fromKey),
    });
  }

  /// Builds a sender from a password map. Used by tests with fake values.
  factory SmtpAuthEmailSender.fromPasswords(Map<String, String?> passwords) {
    final username = passwords[_usernameKey]?.trim() ?? '';
    final from = (passwords[_fromKey]?.trim().isNotEmpty ?? false)
        ? passwords[_fromKey]!.trim()
        : username;
    return SmtpAuthEmailSender(
      host: _nonEmpty(passwords[_hostKey], 'smtp.gmail.com'),
      port: int.tryParse(passwords[_portKey]?.trim() ?? '') ?? 587,
      username: username,
      password: passwords[_passwordKey] ?? '',
      from: from,
    );
  }

  @override
  Future<void> send(AuthEmailMessage message) async {
    if (username.isEmpty || _password.isEmpty || from.isEmpty) {
      throw const AuthEmailDeliveryException('SMTP is not configured.');
    }

    final smtpServer = SmtpServer(
      host,
      port: port,
      username: username,
      password: _password,
      ssl: false,
    );

    final outgoing = mailer.Message()
      ..from = mailer.Address(from, 'Messenger')
      ..recipients.add(message.recipient)
      ..subject = message.subject
      ..text = message.body;

    try {
      await mailer.send(outgoing, smtpServer);
    } catch (_) {
      throw const AuthEmailDeliveryException();
    }
  }

  @override
  String toString() {
    return 'SmtpAuthEmailSender(host: $host, port: $port, username: $username, '
        'from: $from)';
  }

  static String _nonEmpty(String? value, String fallback) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return fallback;
    }
    return trimmed;
  }
}
