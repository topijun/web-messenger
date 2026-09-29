import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';

import '../encryption/encryption_service.dart';
import '../generated/protocol.dart';
import '../media/media_bytes.dart';
import '../users/current_messenger_user.dart';

/// Creates and updates [Profile] rows for the authenticated [MessengerUser].
class Profiles {
  /// Maximum length for [Profile.aboutMe].
  static const maxAboutMeLength = 500;

  /// Maximum original profile-picture size (5 MiB), before encryption.
  static const maxProfileImageBytes = 5 * 1024 * 1024;

  /// Creates a [Profiles] instance.
  const Profiles();

  /// Returns the profile for [userId], if one exists.
  Future<Profile?> findByUserId(
    Session session, {
    required int userId,
    Transaction? transaction,
  }) {
    return Profile.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
      transaction: transaction,
    );
  }

  /// Returns the current user's profile, creating an empty one if needed.
  Future<Profile> getOrCreateMine(Session session) async {
    final stored = await _requireStoredMine(session);
    return _profileForClient(session, stored);
  }

  /// Updates the current user's about-me text.
  Future<Profile> updateMine(
    Session session, {
    required String aboutMe,
  }) async {
    final normalized = aboutMe.trim();
    if (normalized.length > maxAboutMeLength) {
      throw MessengerInvalidProfileInputException(
        field: 'aboutMe',
        message: 'About me must be at most $maxAboutMeLength characters.',
      );
    }

    final stored = await _requireStoredMine(session);
    final updated = await Profile.db.updateRow(
      session,
      stored.copyWith(
        aboutMe: await EncryptionService.of(session).encrypt(normalized),
        updatedAt: DateTime.now(),
      ),
    );
    return _profileForClient(session, updated);
  }

  /// Encrypts and stores a JPEG/PNG as the current user's profile picture.
  Future<ProfileImage> uploadProfileImage(
    Session session, {
    required ByteData bytes,
  }) async {
    final plaintext = uint8ListFromByteData(bytes);
    if (plaintext.length > maxProfileImageBytes) {
      throw MessengerInvalidMediaException(
        code: 'tooLarge',
        message: 'Profile pictures must be at most 5 MB before encryption.',
      );
    }
    final format = ProfileImageFormat.detect(plaintext);
    if (format == null) {
      throw MessengerInvalidMediaException(
        code: 'unsupportedFormat',
        message: 'Profile pictures must be JPEG or PNG.',
      );
    }

    final me = await CurrentMessengerUser.require(session);
    final ciphertext = await EncryptionService.of(session).encryptBytes(
      plaintext,
    );

    return DatabaseUtil.runInTransactionOrSavepoint(session.db, null, (
      transaction,
    ) async {
      final storedProfile = await _requireStoredMine(
        session,
        transaction: transaction,
      );
      final media = await Media.db.insertRow(
        session,
        Media(
          userId: me.id!,
          type: MediaType.image,
          mimeType: format.mimeType,
          size: plaintext.length,
          encryptedData: byteDataFromBytes(ciphertext),
        ),
        transaction: transaction,
      );

      final previousId = storedProfile.profileImageId;
      await Profile.db.updateRow(
        session,
        storedProfile.copyWith(
          profileImageId: media.id,
          updatedAt: DateTime.now(),
        ),
        transaction: transaction,
      );

      if (previousId != null && previousId != media.id) {
        await Media.db.deleteWhere(
          session,
          where: (t) => t.id.equals(previousId),
          transaction: transaction,
        );
      }

      return ProfileImage(
        mediaId: media.id!,
        mimeType: format.mimeType,
        size: plaintext.length,
        bytes: byteDataFromBytes(plaintext),
      );
    });
  }

  /// Profile-image media ids for [userIds]. Missing pictures are null.
  Future<Map<int, int?>> imageIdsByUserIds(
    Session session,
    Iterable<int> userIds, {
    Transaction? transaction,
  }) async {
    final ids = userIds.toSet();
    if (ids.isEmpty) {
      return const {};
    }
    final profiles = await Profile.db.find(
      session,
      where: (t) => t.userId.inSet(ids),
      transaction: transaction,
    );
    return {
      for (final profile in profiles) profile.userId: profile.profileImageId,
    };
  }

  /// Decrypts a profile picture.
  ///
  /// With no [mediaId], returns the current user's picture. With [mediaId],
  /// returns that image only when it is some user's [Profile.profileImageId].
  Future<ProfileImage?> getProfileImage(
    Session session, {
    int? mediaId,
  }) async {
    await CurrentMessengerUser.require(session);
    final resolvedId =
        mediaId ?? (await _requireStoredMine(session)).profileImageId;
    if (resolvedId == null) {
      return null;
    }

    final owner = await Profile.db.findFirstRow(
      session,
      where: (t) => t.profileImageId.equals(resolvedId),
    );
    if (owner == null) {
      throw MessengerMediaNotFoundException(mediaId: resolvedId);
    }

    final media = await Media.db.findById(session, resolvedId);
    if (media == null) {
      throw MessengerMediaNotFoundException(mediaId: resolvedId);
    }

    final clear = await EncryptionService.of(session).decryptBytes(
      uint8ListFromByteData(media.encryptedData),
    );
    return ProfileImage(
      mediaId: media.id!,
      mimeType: media.mimeType,
      size: media.size,
      bytes: byteDataFromBytes(clear),
    );
  }

  Future<Profile> _requireStoredMine(
    Session session, {
    Transaction? transaction,
  }) async {
    final messengerUser = await CurrentMessengerUser.require(
      session,
      transaction: transaction,
    );
    final existing = await findByUserId(
      session,
      userId: messengerUser.id!,
      transaction: transaction,
    );
    if (existing != null) {
      return existing;
    }

    try {
      return await Profile.db.insertRow(
        session,
        Profile(
          userId: messengerUser.id!,
          aboutMe: await EncryptionService.of(session).encrypt(''),
        ),
        transaction: transaction,
      );
    } on DatabaseQueryException catch (error) {
      if (error.code == '23505') {
        final created = await findByUserId(
          session,
          userId: messengerUser.id!,
          transaction: transaction,
        );
        if (created != null) {
          return created;
        }
      }
      rethrow;
    }
  }

  Future<Profile> _profileForClient(Session session, Profile stored) async {
    final plaintext = await EncryptionService.of(
      session,
    ).decrypt(stored.aboutMe);
    return stored.copyWith(aboutMe: plaintext);
  }
}
