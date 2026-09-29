/// Client-side auth field rules. The server remains the source of truth.
class AuthValidators {
  static final _usernamePattern = RegExp(r'^[A-Za-z0-9_.]{3,30}$');
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Trims [raw] and returns it when the address looks valid.
  static String? emailError(String raw) {
    final email = raw.trim();
    if (email.isEmpty) {
      return 'Email is required.';
    }
    if (!_emailPattern.hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  /// Trims [raw] and returns it when the username matches server rules.
  static String? usernameError(String raw) {
    final username = raw.trim();
    if (username.isEmpty) {
      return 'Username is required.';
    }
    if (username.length < 3) {
      return 'Username must be at least 3 characters.';
    }
    if (username.length > 30) {
      return 'Username must be at most 30 characters.';
    }
    if (!_usernamePattern.hasMatch(username)) {
      return 'Use letters, numbers, underscore, or period only.';
    }
    return null;
  }

  /// Returns whether [username] matches the server username pattern.
  static bool isUsernameValid(String username) =>
      usernameError(username) == null;

  /// Returns a password error, or null when the assignment policy is met.
  static String? passwordError(String password) {
    if (password.isEmpty) {
      return 'Password is required.';
    }
    if (password.trim() != password) {
      return 'Password cannot start or end with spaces.';
    }
    if (!PasswordStrength.from(password).isValid) {
      return 'Password does not meet the strength requirements.';
    }
    return null;
  }

  /// Returns an error when [confirmation] does not match [password].
  static String? passwordConfirmationError(String password, String confirmation) {
    if (confirmation.isEmpty) {
      return 'Confirm your password.';
    }
    if (password != confirmation) {
      return 'Passwords do not match.';
    }
    return null;
  }
}

/// Assignment password-strength checks shown in the registration UI.
class PasswordStrength {
  /// Creates a [PasswordStrength] snapshot for [password].
  const PasswordStrength({
    required this.hasMinLength,
    required this.hasLowercase,
    required this.hasUppercase,
    required this.hasDigit,
    required this.hasSpecial,
    required this.hasNoSurroundingSpaces,
  });

  /// Evaluates [password] against the assignment rules.
  factory PasswordStrength.from(String password) {
    return PasswordStrength(
      hasMinLength: password.length >= 8,
      hasLowercase: RegExp(r'[a-z]').hasMatch(password),
      hasUppercase: RegExp(r'[A-Z]').hasMatch(password),
      hasDigit: RegExp(r'[0-9]').hasMatch(password),
      hasSpecial: RegExp(r'[^A-Za-z0-9]').hasMatch(password),
      hasNoSurroundingSpaces: password.trim() == password,
    );
  }

  final bool hasMinLength;
  final bool hasLowercase;
  final bool hasUppercase;
  final bool hasDigit;
  final bool hasSpecial;
  final bool hasNoSurroundingSpaces;

  /// Whether every assignment rule is satisfied.
  bool get isValid =>
      hasMinLength &&
      hasLowercase &&
      hasUppercase &&
      hasDigit &&
      hasSpecial &&
      hasNoSurroundingSpaces;
}
