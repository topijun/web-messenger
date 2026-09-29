import 'dart:async';

import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/features/auth/data/auth_repository.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';

UuidValue testAuthUserId() =>
    UuidValue.fromString('11111111-1111-1111-1111-111111111111');

AuthSuccess testAuthSuccess() {
  return AuthSuccess(
    authStrategy: 'jwt',
    token: 'test-token',
    authUserId: testAuthUserId(),
    scopeNames: {},
  );
}

MessengerUser testMessengerUser({String username = 'Topi.J'}) {
  return MessengerUser(
    authUserId: testAuthUserId(),
    username: username,
    usernameNormalized: username.toLowerCase(),
  );
}

class FakeAuthSession implements AuthSession {
  FakeAuthSession({this.authenticated = false});

  bool authenticated;
  AuthSuccess? stored;

  @override
  bool get isAuthenticated => authenticated;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> applyAuthSuccess(AuthSuccess authSuccess) async {
    stored = authSuccess;
    authenticated = true;
  }

  @override
  Future<void> signOut() async {
    stored = null;
    authenticated = false;
  }
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.loginResult,
    this.loginError,
    this.startRegistrationResult,
    this.startRegistrationError,
    this.verifyRegistrationResult,
    this.verifyRegistrationError,
    this.finishRegistrationResult,
    this.finishRegistrationError,
    this.currentUser,
    this.startPasswordResetResult,
    this.startPasswordResetError,
    this.verifyPasswordResetResult,
    this.verifyPasswordResetError,
    this.finishPasswordResetError,
  });

  AuthSuccess? loginResult;
  Object? loginError;
  UuidValue? startRegistrationResult;
  Object? startRegistrationError;
  String? verifyRegistrationResult;
  Object? verifyRegistrationError;
  AuthSuccess? finishRegistrationResult;
  Object? finishRegistrationError;
  MessengerUser? currentUser;
  UuidValue? startPasswordResetResult;
  Object? startPasswordResetError;
  String? verifyPasswordResetResult;
  Object? verifyPasswordResetError;
  Object? finishPasswordResetError;
  Completer<UuidValue>? startPasswordResetCompleter;

  int startRegistrationCalls = 0;
  String? lastStartUsername;
  String? lastFinishPassword;
  int startPasswordResetCalls = 0;
  String? lastStartPasswordResetEmail;
  String? lastVerifyPasswordResetCode;
  String? lastFinishPasswordResetToken;
  String? lastFinishNewPassword;
  String? lastLoginEmail;
  String? lastLoginPassword;

  @override
  Future<AuthSuccess> login({
    required String email,
    required String password,
  }) async {
    lastLoginEmail = email;
    lastLoginPassword = password;
    if (loginError != null) {
      throw loginError!;
    }
    return loginResult ?? testAuthSuccess();
  }

  @override
  Future<UuidValue> startRegistration({
    required String email,
    required String username,
  }) async {
    startRegistrationCalls += 1;
    lastStartUsername = username;
    if (startRegistrationError != null) {
      throw startRegistrationError!;
    }
    return startRegistrationResult ?? testAuthUserId();
  }

  @override
  Future<String> verifyRegistration({
    required UuidValue accountRequestId,
    required String verificationCode,
  }) async {
    if (verifyRegistrationError != null) {
      throw verifyRegistrationError!;
    }
    return verifyRegistrationResult ?? 'registration-token';
  }

  @override
  Future<AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) async {
    lastFinishPassword = password;
    if (finishRegistrationError != null) {
      throw finishRegistrationError!;
    }
    return finishRegistrationResult ?? testAuthSuccess();
  }

  @override
  Future<UuidValue> startPasswordReset({required String email}) async {
    startPasswordResetCalls += 1;
    lastStartPasswordResetEmail = email;
    if (startPasswordResetCompleter != null) {
      return startPasswordResetCompleter!.future;
    }
    if (startPasswordResetError != null) {
      throw startPasswordResetError!;
    }
    return startPasswordResetResult ?? testAuthUserId();
  }

  @override
  Future<String> verifyPasswordReset({
    required UuidValue passwordResetRequestId,
    required String verificationCode,
  }) async {
    lastVerifyPasswordResetCode = verificationCode;
    if (verifyPasswordResetError != null) {
      throw verifyPasswordResetError!;
    }
    return verifyPasswordResetResult ?? 'reset-token';
  }

  @override
  Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) async {
    lastFinishPasswordResetToken = finishPasswordResetToken;
    lastFinishNewPassword = newPassword;
    if (finishPasswordResetError != null) {
      throw finishPasswordResetError!;
    }
  }

  @override
  Future<MessengerUser?> getCurrentMessengerUser() async => currentUser;
}
