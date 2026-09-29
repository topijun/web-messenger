import 'dart:convert';
import 'dart:typed_data';

import 'package:messenger_server/src/encryption/encryption_service.dart';
import 'package:messenger_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  const testKey =
      '000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f';

  EncryptionService service() =>
      EncryptionService.fromConfiguredSecret(testKey);

  test('encrypt then decrypt returns the original plaintext', () async {
    final crypto = service();
    final stored = await crypto.encrypt('hello phase 7');
    expect(await crypto.decrypt(stored), 'hello phase 7');
  });

  test('ciphertext is not the plaintext and uses the v1 prefix', () async {
    final stored = await service().encrypt('hello phase 7');
    expect(stored, isNot('hello phase 7'));
    expect(stored, startsWith('v1:'));
  });

  test('the same plaintext encrypts to different values', () async {
    final crypto = service();
    final first = await crypto.encrypt('hello phase 7');
    final second = await crypto.encrypt('hello phase 7');
    expect(first, isNot(second));
    expect(await crypto.decrypt(first), 'hello phase 7');
    expect(await crypto.decrypt(second), 'hello phase 7');
  });

  test('tampered ciphertext fails decryption', () async {
    final stored = await service().encrypt('hello phase 7');
    final packed = base64.decode(stored.substring(3));
    packed[packed.length - 1] = packed[packed.length - 1] ^ 0x01;
    final tampered = 'v1:${base64.encode(packed)}';
    await expectLater(
      () => service().decrypt(tampered),
      throwsA(isA<MessengerEncryptedDataException>()),
    );
  });

  test('invalid ciphertext is rejected', () async {
    await expectLater(
      () => service().decrypt('not-ciphertext'),
      throwsA(isA<MessengerEncryptedDataException>()),
    );
    await expectLater(
      () => service().decrypt('v1:@@@'),
      throwsA(isA<MessengerEncryptedDataException>()),
    );
    await expectLater(
      () => service().decrypt('v1:${base64.encode([1, 2, 3])}'),
      throwsA(isA<MessengerEncryptedDataException>()),
    );
  });

  test('invalid encryption key configuration is rejected', () {
    expect(
      () => EncryptionService.fromConfiguredSecret('too-short'),
      throwsA(isA<StateError>()),
    );
    expect(
      () => EncryptionService.fromConfiguredSecret(''),
      throwsA(isA<StateError>()),
    );
    expect(
      () => EncryptionService.fromConfiguredSecret('zz'),
      throwsA(isA<StateError>()),
    );
  });

  test('encryptBytes then decryptBytes returns the original bytes', () async {
    final crypto = service();
    final plaintext = Uint8List.fromList([0xFF, 0xD8, 0xFF, 1, 2, 3]);
    final stored = await crypto.encryptBytes(plaintext);
    expect(await crypto.decryptBytes(stored), plaintext);
  });

  test('binary ciphertext differs from plaintext and is versioned', () async {
    final plaintext = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D]);
    final stored = await service().encryptBytes(plaintext);
    expect(stored, isNot(equals(plaintext)));
    expect(stored.first, 0x01);
  });

  test('the same bytes encrypt to different ciphertext', () async {
    final crypto = service();
    final plaintext = Uint8List.fromList([1, 2, 3, 4, 5]);
    final first = await crypto.encryptBytes(plaintext);
    final second = await crypto.encryptBytes(plaintext);
    expect(first, isNot(equals(second)));
    expect(await crypto.decryptBytes(first), plaintext);
    expect(await crypto.decryptBytes(second), plaintext);
  });

  test('tampered media ciphertext fails decryption', () async {
    final stored = await service().encryptBytes(Uint8List.fromList([9, 8, 7]));
    stored[stored.length - 1] = stored[stored.length - 1] ^ 0x01;
    await expectLater(
      () => service().decryptBytes(stored),
      throwsA(isA<MessengerEncryptedDataException>()),
    );
  });

  test('invalid encrypted media is rejected', () async {
    await expectLater(
      () => service().decryptBytes(Uint8List(0)),
      throwsA(isA<MessengerEncryptedDataException>()),
    );
    await expectLater(
      () => service().decryptBytes(Uint8List.fromList([0x02, 1, 2, 3])),
      throwsA(isA<MessengerEncryptedDataException>()),
    );
    await expectLater(
      () => service().decryptBytes(Uint8List.fromList([0x01, 1, 2, 3])),
      throwsA(isA<MessengerEncryptedDataException>()),
    );
  });
}
