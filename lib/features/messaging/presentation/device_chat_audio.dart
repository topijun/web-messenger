import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:mobile_messenger/features/messaging/domain/chat_audio.dart';
import 'package:mobile_messenger/features/messaging/presentation/audio_recording.dart';
import 'package:record/record.dart';

/// `record` 6.2.1 WAV capture for Android, iOS, and Web.
class DeviceChatAudioRecorder implements ChatAudioRecorder {
  DeviceChatAudioRecorder({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  var _session = false;

  static const _config = RecordConfig(
    encoder: AudioEncoder.wav,
    sampleRate: 16000,
    numChannels: 1,
  );

  @override
  Future<bool> hasPermission() {
    return _recorder.hasPermission();
  }

  @override
  Future<void> start() async {
    final permitted = await _recorder.hasPermission();
    if (!permitted) {
      throw const ChatAudioPermissionDenied();
    }
    final supported = await _recorder.isEncoderSupported(AudioEncoder.wav);
    if (!supported) {
      throw StateError('WAV recording is not supported on this platform.');
    }
    final path = await recordingOutputPath();
    await _recorder.start(_config, path: path);
    _session = true;
  }

  @override
  Future<Uint8List?> stop() async {
    if (!_session && !await _recorder.isRecording()) {
      return null;
    }
    final path = await _recorder.stop();
    _session = false;
    if (path == null || path.isEmpty) {
      return null;
    }
    try {
      return await readRecordingBytes(path);
    } finally {
      await deleteRecordingFile(path);
    }
  }

  @override
  Future<void> cancel() async {
    if (_session || await _recorder.isRecording()) {
      await _recorder.cancel();
    }
    _session = false;
  }

  @override
  Future<void> dispose() async {
    await cancel();
    await _recorder.dispose();
  }
}

/// `audioplayers` 6.7.1 playback of decrypted WAV bytes. One source at a time.
class DeviceChatAudioPlayback implements ChatAudioPlayback {
  DeviceChatAudioPlayback({AudioPlayer? player})
    : _player = player ?? AudioPlayer() {
    _durationSub = _player.onDurationChanged.listen((duration) {
      if (_activeKey == null) {
        return;
      }
      _durations[_activeKey!] = duration;
      _notify();
    });
    _positionSub = _player.onPositionChanged.listen((position) {
      if (_activeKey == null) {
        return;
      }
      _positions[_activeKey!] = position;
      _notify();
    });
    _completeSub = _player.onPlayerComplete.listen((_) {
      final key = _activeKey;
      if (key == null) {
        return;
      }
      _states[key] = ChatAudioPlaybackState.idle;
      _positions[key] = Duration.zero;
      _notify();
    });
  }

  final AudioPlayer _player;
  final List<void Function()> _listeners = [];
  String? _activeKey;
  final Map<String, ChatAudioPlaybackState> _states = {};
  final Map<String, Duration> _durations = {};
  final Map<String, Duration> _positions = {};
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<void>? _completeSub;

  @override
  String? get activeKey => _activeKey;

  @override
  ChatAudioPlaybackState stateFor(String key) {
    return _states[key] ?? ChatAudioPlaybackState.idle;
  }

  @override
  Duration? durationFor(String key) => _durations[key];

  @override
  Duration? positionFor(String key) => _positions[key];

  @override
  Future<void> play({
    required String key,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final previous = _activeKey;
    if (previous != null && previous != key) {
      _states[previous] = ChatAudioPlaybackState.idle;
    }
    _activeKey = key;
    _states[key] = ChatAudioPlaybackState.loading;
    _notify();
    try {
      await _player.stop();
      await _player.play(BytesSource(bytes, mimeType: mimeType));
      _states[key] = ChatAudioPlaybackState.playing;
    } catch (_) {
      _states[key] = ChatAudioPlaybackState.failed;
    }
    _notify();
  }

  @override
  Future<void> pause() async {
    final key = _activeKey;
    if (key == null || _states[key] != ChatAudioPlaybackState.playing) {
      return;
    }
    await _player.pause();
    _states[key] = ChatAudioPlaybackState.paused;
    _notify();
  }

  @override
  Future<void> resume() async {
    final key = _activeKey;
    if (key == null || _states[key] != ChatAudioPlaybackState.paused) {
      return;
    }
    await _player.resume();
    _states[key] = ChatAudioPlaybackState.playing;
    _notify();
  }

  @override
  Future<void> stop() async {
    final key = _activeKey;
    await _player.stop();
    if (key != null) {
      _states[key] = ChatAudioPlaybackState.idle;
      _positions[key] = Duration.zero;
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
    await _durationSub?.cancel();
    await _positionSub?.cancel();
    await _completeSub?.cancel();
    await _player.dispose();
    _listeners.clear();
  }

  void _notify() {
    for (final listener in List<void Function()>.of(_listeners)) {
      listener();
    }
  }
}
