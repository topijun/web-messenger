import 'dart:typed_data';

/// No poster support on this platform.
Future<Uint8List?> extractVideoPoster({
  required Uint8List bytes,
  required String mimeType,
}) async {
  return null;
}
