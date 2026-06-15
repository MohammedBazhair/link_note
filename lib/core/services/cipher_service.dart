import 'dart:convert';

class CipherService {
  CipherService._();

  static const int _salt = 42;
  static const String _key = 'SulgEWv8y0LJq5nz';

  static String encrypt(String input) {
    if (input.isEmpty) return '';

    final bytes = utf8.encode(input);

    final encryptedBytes = List.generate(bytes.length, (i) {
      final keyChar = _key.codeUnitAt(i % _key.length);
      return bytes[i] ^ keyChar ^ _salt;
    });

    return base64Url.encode(encryptedBytes).replaceAll('=', '');
  }

  static String decrypt(String encrypted) {
    if (encrypted.isEmpty) return '';

    try {
      var normalized = encrypted;

      while (normalized.length % 4 != 0) {
        normalized += '=';
      }

      final bytes = base64Url.decode(normalized);

      final decryptedBytes = List.generate(bytes.length, (i) {
        final keyChar = _key.codeUnitAt(i % _key.length);
        return bytes[i] ^ keyChar ^ _salt;
      });

      return utf8.decode(decryptedBytes);
    } catch (_) {
      return 'خطأ في فك التشفير';
    }
  }
}
