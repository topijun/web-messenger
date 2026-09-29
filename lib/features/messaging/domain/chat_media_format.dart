/// Client-side chat media detection. The server still validates magic bytes.
class ChatMediaFormat {
  /// Maximum original image/video size (20 MiB).
  static const maxBytes = 20 * 1024 * 1024;

  /// Maximum original audio size (10 MiB).
  static const maxAudioBytes = 10 * 1024 * 1024;

  /// Canonical WAV PCM header length. Smaller payloads are treated as empty.
  static const wavHeaderBytes = 44;

  /// `audio/wav`
  static const wavMime = 'audio/wav';

  ChatMediaFormat._({
    required this.isVideo,
    required this.mimeType,
    this.isAudio = false,
  });

  /// Whether this is a video rather than an image.
  final bool isVideo;

  /// Whether this is a WAV recording.
  final bool isAudio;

  /// Detected MIME type.
  final String mimeType;

  static const _mp4MajorBrands = {
    'isom',
    'iso2',
    'iso3',
    'iso4',
    'iso5',
    'iso6',
    'mp41',
    'mp42',
    'mp71',
    'avc1',
    'avc3',
    'dash',
    'mp4v',
    'mpeg',
    'hev1',
    'hvc1',
  };

  static const _m4vMajorBrands = {'M4V '};

  static const _quickTimeMajorBrands = {'qt  '};

  static const _threeGpMajorBrands = {
    '3gp4',
    '3gp5',
    '3gp6',
    '3gp7',
    '3gp8',
    '3gp9',
    '3g2a',
    '3g2b',
    '3g2c',
  };

  /// WAV (`RIFF....WAVE`) from magic bytes; otherwise null.
  static ChatMediaFormat? detectAudio(List<int> bytes) {
    if (_isWav(bytes)) {
      return ChatMediaFormat._(
        isVideo: false,
        isAudio: true,
        mimeType: wavMime,
      );
    }
    return null;
  }

  /// JPEG, PNG, or a supported video container from magic bytes; otherwise null.
  static ChatMediaFormat? detect(List<int> bytes) {
    if (_isJpeg(bytes)) {
      return ChatMediaFormat._(isVideo: false, mimeType: 'image/jpeg');
    }
    if (_isPng(bytes)) {
      return ChatMediaFormat._(isVideo: false, mimeType: 'image/png');
    }
    final brand = _ftypMajorBrand(bytes);
    if (brand != null) {
      if (_mp4MajorBrands.contains(brand)) {
        return ChatMediaFormat._(isVideo: true, mimeType: 'video/mp4');
      }
      if (_m4vMajorBrands.contains(brand)) {
        return ChatMediaFormat._(isVideo: true, mimeType: 'video/x-m4v');
      }
      if (_quickTimeMajorBrands.contains(brand)) {
        return ChatMediaFormat._(isVideo: true, mimeType: 'video/quicktime');
      }
      if (_threeGpMajorBrands.contains(brand)) {
        return ChatMediaFormat._(isVideo: true, mimeType: 'video/3gpp');
      }
    }
    if (_isWebm(bytes)) {
      return ChatMediaFormat._(isVideo: true, mimeType: 'video/webm');
    }
    return null;
  }

  static bool _isJpeg(List<int> bytes) {
    return bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF;
  }

  static bool _isPng(List<int> bytes) {
    return bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A;
  }

  static String? _ftypMajorBrand(List<int> bytes) {
    if (bytes.length < 12) {
      return null;
    }
    if (bytes[4] != 0x66 ||
        bytes[5] != 0x74 ||
        bytes[6] != 0x79 ||
        bytes[7] != 0x70) {
      return null;
    }
    return String.fromCharCodes(bytes.sublist(8, 12));
  }

  static bool _isWav(List<int> bytes) {
    if (bytes.length < wavHeaderBytes) {
      return false;
    }
    return bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x41 &&
        bytes[10] == 0x56 &&
        bytes[11] == 0x45;
  }

  static bool _isWebm(List<int> bytes) {
    if (bytes.length < 8) {
      return false;
    }
    if (bytes[0] != 0x1A ||
        bytes[1] != 0x45 ||
        bytes[2] != 0xDF ||
        bytes[3] != 0xA3) {
      return false;
    }
    final end = bytes.length < 256 ? bytes.length : 256;
    if (_containsAscii(bytes, end, 'matroska')) {
      return false;
    }
    return _containsAscii(bytes, end, 'webm');
  }

  static bool _containsAscii(List<int> bytes, int end, String ascii) {
    final needle = ascii.codeUnits;
    if (end < needle.length) {
      return false;
    }
    final lastStart = end - needle.length;
    for (var i = 0; i <= lastStart; i++) {
      var matched = true;
      for (var j = 0; j < needle.length; j++) {
        if (bytes[i + j] != needle[j]) {
          matched = false;
          break;
        }
      }
      if (matched) {
        return true;
      }
    }
    return false;
  }
}
