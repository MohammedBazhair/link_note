import 'dart:convert';

class CipherService {
  CipherService._();
  // مفتاح سري خاص بك (يمكنك تغيير هذه الأرقام لضمان تفرد التشفير)
  static const int _salt = 42;
  static const String _key = 'SulgEWv8y0LJq5nz';

  /// دالة تشفير النصوص
  static String encrypt(String input) {
    if (input.isEmpty) return '';

    // 1. تحويل النص إلى Bytes
    final List<int> bytes = utf8.encode(input);

    // 2. معالجة كل Byte (إزاحة بسيطة بناءً على المفتاح والملح)
    final List<int> encryptedBytes = [];
    for (int i = 0; i < bytes.length; i++) {
      // عملية حسابية ثابتة لضمان نفس النتيجة دائماً
      final int keyChar = _key.codeUnitAt(i % _key.length);
      encryptedBytes.add(bytes[i] ^ keyChar ^ _salt);
    }

    // 3. تحويل النتيجة إلى Base64 ليكون المخرج "جميلاً"
    return base64Url.encode(encryptedBytes).replaceAll('=', '');
  }

  /// دالة فك التشفير
  static String decrypt(String encrypted) {
    if (encrypted.isEmpty) return '';

    try {
      // 1. فك ترميز Base64
      // إضافة الـ padding المفقود إن وجد
      String normalized = encrypted;
      while (normalized.length % 4 != 0) {
        normalized += '=';
      }
      final List<int> bytes = base64Url.decode(normalized);

      // 2. عكس العملية الحسابية
      final List<int> decryptedBytes = [];
      for (int i = 0; i < bytes.length; i++) {
        final int keyChar = _key.codeUnitAt(i % _key.length);
        decryptedBytes.add(bytes[i] ^ keyChar ^ _salt);
      }

      // 3. تحويل الـ Bytes إلى نص مفهوم
      return utf8.decode(decryptedBytes);
    } catch (e) {
      return 'خطأ في فك التشفير';
    }
  }
}
