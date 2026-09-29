/// Builds the conversation typing-indicator label from usernames.
///
/// Returns null when nobody is typing.
String? formatTypingLabel(Iterable<String> usernames) {
  final names = [
    for (final name in usernames)
      if (name.trim().isNotEmpty) name.trim(),
  ]..sort();
  if (names.isEmpty) {
    return null;
  }
  if (names.length == 1) {
    return '${names.single} is typing…';
  }
  if (names.length == 2) {
    return '${names[0]} and ${names[1]} are typing…';
  }
  final others = names.length - 2;
  final otherLabel = others == 1 ? 'other' : 'others';
  return '${names[0]}, ${names[1]} and $others $otherLabel are typing…';
}
