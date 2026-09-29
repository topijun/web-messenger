import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:serverpod/serverpod.dart' hide Message;

import '../generated/protocol.dart';

/// AES-256-GCM application-layer encryption for values stored in PostgreSQL.
///
/// This is **not** end-to-end encryption. The Flutter client sends and receives
/// plaintext over the authenticated Serverpod API. The server encrypts before
/// insert/update and decrypts before returning data to the caller.
///
/// Encrypted fields:
/// - [Message.encryptedText]
/// - [Profile.aboutMe]
/// - [Chat.name] (group chats only; direct chats keep `name` null)
/// - [Media.encryptedData] (profile pictures and chat image/video)
///
/// Not encrypted (query/auth metadata, not message content):
/// - primary/foreign keys, timestamps, enums, membership rows
/// - usernames and emails (required for authentication and lookup)
/// - [Chat.lastMessageAt] (ordering metadata; no message preview is stored)
/// - [Media.mimeType], [Media.size], [Media.type]
///
/// String storage format:
/// `v1:` + standard Base64 of the cryptography [SecretBox] concatenation
/// (12-byte nonce + ciphertext + 16-byte GCM tag).
///
/// Binary storage format (media):
/// one version byte `0x01` followed by the same [SecretBox] concatenation.
/// A fresh nonce is generated for every [encrypt] / [encryptBytes] call.
class EncryptionService {
  /// [passwords.yaml] / `SERVERPOD_PASSWORD_applicationEncryptionKey` key name.
  static const passwordKey = 'applicationEncryptionKey';

  static const _versionPrefix = 'v1:';
  static const _binaryVersion = 0x01;
  static const _keyLength = 32;
  static const _nonceLength = 12;
  static const _macLength = 16;

  static final _algorithm = AesGcm.with256bits(nonceLength: _nonceLength);

  EncryptionService._(this._secretKey);

  final SecretKey _secretKey;

  /// Loads and validates the process-wide key from Serverpod passwords.
  ///
  /// Throws [StateError] if the key is missing or not exactly 32 bytes.
  /// Call this at server startup so a missing key fails before serving traffic.
  static EncryptionService initialize(Serverpod pod) {
    final configured = pod.getPassword(passwordKey);
    if (configured == null || configured.isEmpty) {
      throw StateError(
        'Missing $passwordKey. Add a 32-byte key to config/passwords.yaml '
        '(shared or the current run mode) or set '
        'SERVERPOD_PASSWORD_$passwordKey. '
        'Generate with: openssl rand -hex 32. '
        'Do not generate a new key on every start; existing ciphertext would '
        'become unreadable.',
      );
    }
    return EncryptionService.fromConfiguredSecret(configured);
  }

  /// Builds a service from a configured secret string.
  ///
  /// Accepts 64 hex characters or Base64 that decodes to exactly 32 bytes.
  factory EncryptionService.fromConfiguredSecret(String configured) {
    final keyBytes = _parseKey(configured.trim());
    if (keyBytes == null) {
      throw StateError(
        '$passwordKey must be exactly 32 bytes (64 hex characters or Base64). '
        'Generate with: openssl rand -hex 32.',
      );
    }
    return EncryptionService._(SecretKeyData(keyBytes));
  }

  /// Service for the current request, using [Session.passwords].
  factory EncryptionService.of(Session session) {
    final configured = session.passwords[passwordKey];
    if (configured == null || configured.isEmpty) {
      throw StateError(
        'Missing $passwordKey in Serverpod passwords for this run mode.',
      );
    }
    return EncryptionService.fromConfiguredSecret(configured);
  }

  /// Encrypts UTF-8 [plaintext] with a fresh nonce.
  ///
  /// The returned string is safe to store in a text column. It is never equal
  /// to [plaintext] for non-empty input.
  Future<String> encrypt(String plaintext) async {
    final secretBox = await _algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: _secretKey,
    );
    final packed = secretBox.concatenation();
    return '$_versionPrefix${base64.encode(packed)}';
  }

  /// Decrypts a value previously produced by [encrypt].
  ///
  /// Throws [MessengerEncryptedDataException] on malformed or tampered input.
  /// Does not include the ciphertext, key, or plaintext in the exception.
  Future<String> decrypt(String stored) async {
    if (!stored.startsWith(_versionPrefix)) {
      throw MessengerEncryptedDataException(
        message: 'Stored data could not be decrypted.',
      );
    }
    final encoded = stored.substring(_versionPrefix.length);
    late final Uint8List packed;
    try {
      packed = Uint8List.fromList(base64.decode(encoded));
    } on FormatException {
      throw MessengerEncryptedDataException(
        message: 'Stored data could not be decrypted.',
      );
    }

    try {
      final secretBox = SecretBox.fromConcatenation(
        packed,
        nonceLength: _nonceLength,
        macLength: _macLength,
      );
      final clear = await _algorithm.decrypt(
        secretBox,
        secretKey: _secretKey,
      );
      return utf8.decode(clear);
    } on MessengerEncryptedDataException {
      rethrow;
    } catch (_) {
      throw MessengerEncryptedDataException(
        message: 'Stored data could not be decrypted.',
      );
    }
  }

  /// Encrypts raw [plaintext] bytes with a fresh nonce.
  ///
  /// Returns versioned packed bytes for a `bytea` column. The result is never
  /// equal to [plaintext] for non-empty input. Not Base64-encoded.
  Future<Uint8List> encryptBytes(List<int> plaintext) async {
    final secretBox = await _algorithm.encrypt(
      plaintext,
      secretKey: _secretKey,
    );
    final packed = secretBox.concatenation();
    return Uint8List.fromList([_binaryVersion, ...packed]);
  }

  /// Decrypts a value previously produced by [encryptBytes].
  ///
  /// Throws [MessengerEncryptedDataException] on malformed or tampered input.
  /// Does not include the ciphertext, key, or plaintext in the exception.
  Future<Uint8List> decryptBytes(List<int> stored) async {
    if (stored.isEmpty || stored[0] != _binaryVersion) {
      throw MessengerEncryptedDataException(
        message: 'Stored data could not be decrypted.',
      );
    }
    final packed = Uint8List.fromList(stored.sublist(1));
    try {
      final secretBox = SecretBox.fromConcatenation(
        packed,
        nonceLength: _nonceLength,
        macLength: _macLength,
      );
      final clear = await _algorithm.decrypt(
        secretBox,
        secretKey: _secretKey,
      );
      return Uint8List.fromList(clear);
    } on MessengerEncryptedDataException {
      rethrow;
    } catch (_) {
      throw MessengerEncryptedDataException(
        message: 'Stored data could not be decrypted.',
      );
    }
  }

  static List<int>? _parseKey(String configured) {
    if (configured.length == 64 &&
        RegExp(r'^[0-9a-fA-F]+$').hasMatch(configured)) {
      final bytes = <int>[];
      for (var i = 0; i < 64; i += 2) {
        bytes.add(int.parse(configured.substring(i, i + 2), radix: 16));
      }
      return bytes;
    }
    try {
      final decoded = base64.decode(configured);
      if (decoded.length == _keyLength) {
        return decoded;
      }
    } on FormatException {
      return null;
    }
    return null;
  }
}
