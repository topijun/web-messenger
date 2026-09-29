import 'dart:typed_data';

import '../generated/protocol.dart';

/// Converts Serverpod [ByteData] to a view of its bytes.
Uint8List uint8ListFromByteData(ByteData data) {
  return Uint8List.sublistView(data);
}

/// Wraps [bytes] as [ByteData] without copying when already a [Uint8List].
ByteData byteDataFromBytes(List<int> bytes) {
  final list = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  return ByteData.sublistView(list);
}

/// JPEG / PNG detection from file magic bytes. Does not trust filenames.
class ProfileImageFormat {
  ProfileImageFormat._(this.mimeType);

  /// `image/jpeg`
  static const jpegMime = 'image/jpeg';

  /// `image/png`
  static const pngMime = 'image/png';

  /// Detected MIME type.
  final String mimeType;

  /// JPEG if the payload starts with `FF D8 FF`.
  static bool isJpeg(List<int> bytes) => ChatMediaFormat.isJpeg(bytes);

  /// PNG if the payload starts with the 8-byte PNG signature.
  static bool isPng(List<int> bytes) => ChatMediaFormat.isPng(bytes);

  /// Returns the format, or null when the bytes are not JPEG or PNG.
  static ProfileImageFormat? detect(List<int> bytes) {
    if (isJpeg(bytes)) {
      return ProfileImageFormat._(jpegMime);
    }
    if (isPng(bytes)) {
      return ProfileImageFormat._(pngMime);
    }
    return null;
  }
}

/// Image, video, and audio detection from magic bytes for chat media.
///
/// Supported:
/// - JPEG (`FF D8 FF`)
/// - PNG (8-byte signature)
/// - MP4 / ISO BMFF (`ftyp` with an MP4-compatible major brand, including HEVC)
/// - M4V (`ftyp` major brand `M4V `)
/// - QuickTime / MOV (`ftyp` major brand `qt  `)
/// - 3GP / 3G2 (`ftyp` with a 3GPP major brand)
/// - WebM (EBML header plus ASCII `webm` DocType)
/// - WAV (`RIFF....WAVE`)
///
/// Filenames and client MIME types are ignored. [detect] is image/video only;
/// use [detectAudio] for recordings. HEIC/HEIF image brands are not video.
class ChatMediaFormat {
  ChatMediaFormat._({required this.type, required this.mimeType});

  /// `image/jpeg`
  static const jpegMime = ProfileImageFormat.jpegMime;

  /// `image/png`
  static const pngMime = ProfileImageFormat.pngMime;

  /// `video/mp4`
  static const mp4Mime = 'video/mp4';

  /// `video/webm`
  static const webmMime = 'video/webm';

  /// `video/quicktime`
  static const quickTimeMime = 'video/quicktime';

  /// `video/x-m4v`
  static const m4vMime = 'video/x-m4v';

  /// `video/3gpp`
  static const threeGpMime = 'video/3gpp';

  /// `audio/wav`
  static const wavMime = 'audio/wav';

  /// Canonical WAV PCM header length. Smaller payloads are treated as empty.
  static const wavHeaderBytes = 44;

  /// Detected [MediaType].
  final MediaType type;

  /// Detected MIME type.
  final String mimeType;

  /// ISO BMFF major brands treated as `video/mp4`.
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

  /// JPEG if the payload starts with `FF D8 FF`.
  static bool isJpeg(List<int> bytes) {
    return bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF;
  }

  /// PNG if the payload starts with the 8-byte PNG signature.
  static bool isPng(List<int> bytes) {
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

  /// MP4 if the first box is `ftyp` with an MP4-compatible major brand.
  static bool isMp4(List<int> bytes) {
    final brand = _ftypMajorBrand(bytes);
    return brand != null && _mp4MajorBrands.contains(brand);
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

  /// WebM if the payload is EBML with a `webm` DocType, not Matroska.
  static bool isWebm(List<int> bytes) {
    if (bytes.length < 8) {
      return false;
    }
    if (bytes[0] != 0x1A ||
        bytes[1] != 0x45 ||
        bytes[2] != 0xDF ||
        bytes[3] != 0xA3) {
      return false;
    }
    final headerLength = bytes.length < 256 ? bytes.length : 256;
    if (_containsAscii(bytes, 0, headerLength, 'matroska')) {
      return false;
    }
    return _containsAscii(bytes, 0, headerLength, 'webm');
  }

  /// WAV if the payload is a RIFF container with a WAVE form type.
  static bool isWav(List<int> bytes) {
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

  /// Returns audio format, or null when the bytes are not a supported recording.
  static ChatMediaFormat? detectAudio(List<int> bytes) {
    if (isWav(bytes)) {
      return ChatMediaFormat._(type: MediaType.audio, mimeType: wavMime);
    }
    return null;
  }

  /// Returns the image/video format, or null when the bytes are not supported.
  static ChatMediaFormat? detect(List<int> bytes) {
    if (isJpeg(bytes)) {
      return ChatMediaFormat._(type: MediaType.image, mimeType: jpegMime);
    }
    if (isPng(bytes)) {
      return ChatMediaFormat._(type: MediaType.image, mimeType: pngMime);
    }
    final brand = _ftypMajorBrand(bytes);
    if (brand != null) {
      if (_mp4MajorBrands.contains(brand)) {
        return ChatMediaFormat._(type: MediaType.video, mimeType: mp4Mime);
      }
      if (_m4vMajorBrands.contains(brand)) {
        return ChatMediaFormat._(type: MediaType.video, mimeType: m4vMime);
      }
      if (_quickTimeMajorBrands.contains(brand)) {
        return ChatMediaFormat._(
          type: MediaType.video,
          mimeType: quickTimeMime,
        );
      }
      if (_threeGpMajorBrands.contains(brand)) {
        return ChatMediaFormat._(type: MediaType.video, mimeType: threeGpMime);
      }
    }
    if (isWebm(bytes)) {
      return ChatMediaFormat._(type: MediaType.video, mimeType: webmMime);
    }
    return null;
  }

  static bool _containsAscii(
    List<int> bytes,
    int start,
    int end,
    String ascii,
  ) {
    final needle = ascii.codeUnits;
    if (needle.isEmpty || end - start < needle.length) {
      return false;
    }
    final lastStart = end - needle.length;
    for (var i = start; i <= lastStart; i++) {
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
