import 'dart:typed_data';

/// Recording and playback abstractions so widget tests do not need plugins.
enum ChatAudioPlaybackState {
  /// No active source for this key.
  idle,

  /// Fetching or preparing bytes.
  loading,

  /// Currently playing.
  playing,

  /// Paused and resumable.
  paused,

  /// Last play attempt failed.
  failed,
}

/// Thrown when the microphone permission is not granted.
class ChatAudioPermissionDenied implements Exception {
  /// Creates a [ChatAudioPermissionDenied].
  const ChatAudioPermissionDenied();
}

/// Microphone capture for one conversation. Implementations must be disposable.
abstract class ChatAudioRecorder {
  /// Returns whether recording is allowed. May prompt the user.
  Future<bool> hasPermission();

  /// Starts a new WAV recording session.
  Future<void> start();

  /// Stops recording and returns WAV bytes, or null when nothing was captured.
  Future<Uint8List?> stop();

  /// Discards the current session and any temporary file.
  Future<void> cancel();

  /// Releases native recorder resources.
  Future<void> dispose();
}

/// One-at-a-time audio playback for a conversation.
abstract class ChatAudioPlayback {
  /// Local item key currently loaded into the player, if any.
  String? get activeKey;

  /// Playback state for [key].
  ChatAudioPlaybackState stateFor(String key);

  /// Known duration for [key], if reported by the player.
  Duration? durationFor(String key);

  /// Current position for [key], if playing or paused.
  Duration? positionFor(String key);

  /// Starts [key], stopping any other active audio.
  Future<void> play({
    required String key,
    required Uint8List bytes,
    required String mimeType,
  });

  /// Pauses the active audio if it is playing.
  Future<void> pause();

  /// Resumes the active audio if it is paused.
  Future<void> resume();

  /// Stops playback and clears the active key.
  Future<void> stop();

  /// Releases player resources.
  Future<void> dispose();

  /// Rebuilds bubbles when play state changes.
  void addListener(void Function() listener);

  /// Removes a [addListener] registration.
  void removeListener(void Function() listener);
}

/// Formats a duration as `m:ss` for the composer and audio bubbles.
String formatAudioClock(Duration duration) {
  final total = duration.inSeconds;
  final minutes = total ~/ 60;
  final seconds = (total % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
