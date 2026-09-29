/// Assignment password policy used by official Serverpod Email IDP validation.
bool messengerPasswordPolicy(String password) {
  if (password.trim() != password || password.length < 8) {
    return false;
  }

  return RegExp(r'[a-z]').hasMatch(password) &&
      RegExp(r'[A-Z]').hasMatch(password) &&
      RegExp(r'[0-9]').hasMatch(password) &&
      RegExp(r'[^A-Za-z0-9]').hasMatch(password);
}
