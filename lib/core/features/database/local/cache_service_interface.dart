abstract interface class LocalCacheService {
  Future<bool> setString({required String key, required String value});

  String? getString({required String key});

  Future<bool> setBool({required String key, required bool value});

  bool? getBool({required String key});

  Future<bool> setInt({required String key, required int value});

  int? getInt({required String key});

  Future<bool> setStringList({
    required String key,
    required List<String> value,
  });

  List<String>? getStringList({required String key});

  Future<bool> remove({required String key});

  Future<bool> clear();
}

abstract interface class SecureCacheService {
  Future<void> setString({required String key, required String value});

  Future<String?> getString({required String key});

  Future<void> remove({required String key});

  Future<void> clear();
}
