/// High-level authentication status for the Messenger client.
enum AuthStatus {
  /// Restoring a Serverpod session from secure storage.
  checking,

  /// No valid Serverpod session.
  unauthenticated,

  /// Registration started; waiting for the email verification code.
  awaitingVerification,

  /// A Serverpod session is active.
  authenticated,

  /// The last authentication or registration action failed.
  error,
}

/// Snapshot of Messenger authentication for presentation.
class AuthState {
  /// Creates an [AuthState].
  const AuthState({
    required this.status,
    this.username,
    this.pendingEmail,
    this.pendingUsername,
    this.errorMessage,
    this.isBusy = false,
  });

  /// Initial startup state.
  const AuthState.checking() : this(status: AuthStatus.checking, isBusy: true);

  /// Signed-out state.
  const AuthState.unauthenticated({String? errorMessage})
    : this(status: AuthStatus.unauthenticated, errorMessage: errorMessage);

  final AuthStatus status;
  final String? username;
  final String? pendingEmail;
  final String? pendingUsername;
  final String? errorMessage;
  final bool isBusy;

  /// Whether a Serverpod session is currently active.
  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    String? username,
    String? pendingEmail,
    String? pendingUsername,
    String? errorMessage,
    bool? isBusy,
    bool clearError = false,
    bool clearUsername = false,
    bool clearPendingEmail = false,
    bool clearPendingUsername = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      username: clearUsername ? null : username ?? this.username,
      pendingEmail: clearPendingEmail ? null : pendingEmail ?? this.pendingEmail,
      pendingUsername: clearPendingUsername
          ? null
          : pendingUsername ?? this.pendingUsername,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isBusy: isBusy ?? this.isBusy,
    );
  }
}
