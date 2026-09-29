import 'dart:typed_data';

import 'package:mobile_messenger/features/profile/data/profile_repository.dart';

/// In-memory cache of decrypted profile pictures keyed by media id.
class ProfileImageStore {
  /// Creates a [ProfileImageStore].
  ProfileImageStore(this._repository);

  final ProfileRepository _repository;
  final _bytes = <int, Uint8List>{};
  final _inFlight = <int, Future<Uint8List?>>{};
  final _failed = <int>{};
  var _loadCalls = 0;

  /// Successful fetches recorded for tests.
  int get loadCalls => _loadCalls;

  /// Cached bytes for [mediaId], if already loaded.
  Uint8List? cachedBytes(int mediaId) => _bytes[mediaId];

  /// Stores [bytes] for [mediaId] after a local upload.
  void remember(int mediaId, Uint8List bytes) {
    _bytes[mediaId] = bytes;
    _failed.remove(mediaId);
  }

  /// Loads [mediaId] once and reuses the result on later calls.
  Future<Uint8List?> bytesFor(int mediaId) {
    final cached = _bytes[mediaId];
    if (cached != null) {
      return Future<Uint8List?>.value(cached);
    }
    if (_failed.contains(mediaId)) {
      return Future<Uint8List?>.value(null);
    }
    return _inFlight[mediaId] ??= _load(mediaId);
  }

  Future<Uint8List?> _load(int mediaId) async {
    _loadCalls += 1;
    try {
      final image = await _repository.getProfileImage(mediaId: mediaId);
      if (image == null) {
        _failed.add(mediaId);
        return null;
      }
      final bytes = profileImageBytes(image);
      _bytes[mediaId] = bytes;
      return bytes;
    } catch (_) {
      _failed.add(mediaId);
      return null;
    } finally {
      _inFlight.remove(mediaId);
    }
  }
}
