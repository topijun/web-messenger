import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'profiles.dart';

/// Authenticated access to the current user's [Profile].
class ProfileEndpoint extends Endpoint {
  static const _profiles = Profiles();

  @override
  bool get requireLogin => true;

  /// Returns the signed-in user's profile, creating one if missing.
  Future<Profile> getMine(Session session) {
    return _profiles.getOrCreateMine(session);
  }

  /// Updates the signed-in user's about-me text.
  Future<Profile> updateMine(
    Session session, {
    required String aboutMe,
  }) {
    return _profiles.updateMine(session, aboutMe: aboutMe);
  }

  /// Uploads a JPEG or PNG (max 5 MB) as the signed-in user's profile picture.
  ///
  /// The server validates magic bytes, encrypts with AES-256-GCM, and stores
  /// ciphertext in PostgreSQL. Replaces any previous picture.
  Future<ProfileImage> uploadProfileImage(
    Session session, {
    required ByteData bytes,
  }) {
    return _profiles.uploadProfileImage(session, bytes: bytes);
  }

  /// Returns a decrypted profile picture.
  ///
  /// Omitting [mediaId] returns the current user's picture. Passing [mediaId]
  /// returns that image when it is a stored profile picture.
  Future<ProfileImage?> getProfileImage(Session session, {int? mediaId}) {
    return _profiles.getProfileImage(session, mediaId: mediaId);
  }
}
