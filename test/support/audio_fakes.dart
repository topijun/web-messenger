import 'dart:typed_data';

import 'package:mobile_messenger/features/messaging/domain/chat_audio.dart';

import 'message_fakes.dart';

/// In-memory recorder for conversation widget and controller tests.
class FakeChatAudioRecorder implements ChatAudioRecorder {
  /// Creates a [FakeChatAudioRecorder].
  FakeChatAudioRecorder({Uint8List? recordedBytes})
    : recordedBytes = recordedBytes ?? testWavBytes();

  Uint8List recordedBytes;
  var permissionGranted = true;
  Object? startError;
  Object? stopError;
  var started = false;
  var cancelled = false;
  var disposed = false;
  var startCount = 0;

  @override
  Future<bool> hasPermission() async => permissionGranted;

  @override
  Future<void> start() async {
    if (startError != null) {
      throw startError!;
    }
    started = true;
    cancelled = false;
    startCount += 1;
  }

  @override
  Future<Uint8List?> stop() async {
    started = false;
    if (stopError != null) {
      throw stopError!;
    }
    return recordedBytes;
  }

  @override
  Future<void> cancel() async {
    started = false;
    cancelled = true;
  }

  @override
  Future<void> dispose() async {
    started = false;
    disposed = true;
  }
}

/// In-memory one-at-a-time player for conversation widget tests.
class FakeChatAudioPlayback implements ChatAudioPlayback {
  String? _activeKey;
  Object? playError;
  final Map<String, ChatAudioPlaybackState> states = {};
  final Map<String, Duration> durations = {};
  final Map<String, Duration> positions = {};
  final List<void Function()> _listeners = [];
  var disposed = false;
  var playCount = 0;
  final playedKeys = <String>[];

  @override
  String? get activeKey => _activeKey;

  @override
  ChatAudioPlaybackState stateFor(String key) {
    return states[key] ?? ChatAudioPlaybackState.idle;
  }

  @override
  Duration? durationFor(String key) => durations[key];

  @override
  Duration? positionFor(String key) => positions[key];

  @override
  Future<void> play({
    required String key,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    playCount += 1;
    playedKeys.add(key);
    final previous = _activeKey;
    if (previous != null && previous != key) {
      states[previous] = ChatAudioPlaybackState.idle;
    }
    _activeKey = key;
    durations[key] ??= const Duration(seconds: 5);
    positions[key] = Duration.zero;
    if (playError != null) {
      states[key] = ChatAudioPlaybackState.failed;
      _notify();
      return;
    }
    states[key] = ChatAudioPlaybackState.playing;
    _notify();
  }

  @override
  Future<void> pause() async {
    final key = _activeKey;
    if (key == null) {
      return;
    }
    states[key] = ChatAudioPlaybackState.paused;
    _notify();
  }

  @override
  Future<void> resume() async {
    final key = _activeKey;
    if (key == null) {
      return;
    }
    states[key] = ChatAudioPlaybackState.playing;
    _notify();
  }

  @override
  Future<void> stop() async {
    final key = _activeKey;
    if (key != null) {
      states[key] = ChatAudioPlaybackState.idle;
    }
    _activeKey = null;
    _notify();
  }

  @override
  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    _listeners.clear();
  }

  void _notify() {
    for (final listener in List<void Function()>.of(_listeners)) {
      listener();
    }
  }
}
