import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Temporary WAV path for the `record` package on IO platforms.
Future<String> recordingOutputPath() async {
  final directory = await getTemporaryDirectory();
  return '${directory.path}/messenger_audio_${DateTime.now().microsecondsSinceEpoch}.wav';
}

/// Reads the WAV file produced by [AudioRecorder.stop].
Future<Uint8List> readRecordingBytes(String path) {
  return File(path).readAsBytes();
}

/// Removes a temporary recording file after bytes have been copied.
Future<void> deleteRecordingFile(String path) async {
  final file = File(path);
  if (await file.exists()) {
    await file.delete();
  }
}
