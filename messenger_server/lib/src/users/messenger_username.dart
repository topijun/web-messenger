import '../generated/protocol.dart';

/// Server-side Messenger username rules.
class MessengerUsername {
  static final _pattern = RegExp(r'^[A-Za-z0-9_.]{3,30}$');

  /// Trims [raw] and returns the display username if it is valid.
  ///
  /// Original casing is preserved. Throws [MessengerInvalidUsernameException]
  /// when the value does not match the allowed pattern.
  static String display(String raw) {
    final username = raw.trim();
    if (!_pattern.hasMatch(username)) {
      throw MessengerInvalidUsernameException(username: raw);
    }
    return username;
  }

  /// Returns the case-insensitive form used for uniqueness checks.
  static String normalized(String displayUsername) =>
      displayUsername.toLowerCase();
}
