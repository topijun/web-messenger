import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import 'src/auth/password_policy.dart';
import 'src/email/auth_email_hooks.dart';
import 'src/email/auth_email_service.dart';
import 'src/email/smtp_auth_email_sender.dart';
import 'src/encryption/encryption_service.dart';
import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/users/messenger_registration.dart';
import 'src/web/routes/app_config_route.dart';
import 'src/web/routes/root.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  final devMode = args.contains('--dev-mode');
  final serverpodArgs = [
    for (final arg in args)
      if (arg != '--dev-mode') arg,
  ];

  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(serverpodArgs, Protocol(), Endpoints());
  EncryptionService.initialize(pod);
  final authEmailHooks = AuthEmailHooks(
    AuthEmailService(SmtpAuthEmailSender.fromServerpod(pod)),
    devMode: devMode,
  );

  // Initialize authentication services for the server.
  // Token managers will be used to validate and issue authentication keys,
  // and the identity providers will be the authentication options available for users.
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      // Use JWT for authentication keys towards the server.
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      // Configure the email identity provider for email/password authentication.
      EmailIdpConfigFromPasswords(
        sendRegistrationVerificationCode:
            authEmailHooks.sendRegistrationVerificationCode,
        sendPasswordResetVerificationCode:
            authEmailHooks.sendPasswordResetVerificationCode,
        passwordValidationFunction: messengerPasswordPolicy,
        onAfterAccountCreated: MessengerRegistration.attachMessengerUser,
      ),
    ],
  );

  // Setup a default page at the web root.
  // These are used by the default page.
  pod.webServer.addRoute(RootRoute(), '/');
  pod.webServer.addRoute(RootRoute(), '/index.html');

  // Serve all files in the web/static relative directory under /.
  // These are used by the default web page.
  final root = Directory(Uri(path: 'web/static').toFilePath());
  pod.webServer.addRoute(StaticRoute.directory(root));

  // Setup the app config route.
  // We build this configuration based on the servers api url and serve it to
  // the flutter app.
  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/app/assets/assets/config.json',
  );

  // Checks if the flutter web app has been built and serves it if it has.
  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    // Serve the flutter web app under the /app path.
    pod.webServer.addRoute(
      FlutterRoute(
        Directory(
          Uri(path: 'web/app').toFilePath(),
        ),
      ),
      '/app',
    );
  } else {
    // If the flutter web app has not been built, serve the build app page.
    pod.webServer.addRoute(
      StaticRoute.file(
        File(
          Uri(path: 'web/pages/build_flutter_app.html').toFilePath(),
        ),
      ),
      '/app/**',
    );
  }

  // Start the server.
  await pod.start();
}
