import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LocalCacheService {
  Future<bool> setString({required String key, required String value});

  Future<String?> getString({required String key});

  Future<bool> setBool({required String key, required bool value});

  Future<bool?> getBool({required String key});

  Future<bool> setInt({required String key, required int value});

  Future<int?> getInt({required String key});

  Future<bool> setStringList({
    required String key,
    required List<String> value,
  });

  Future<List<String>?> getStringList({required String key});

  Future<bool> remove({required String key});

  Future<bool> clear();
}

class LocalCacheServiceImpl implements LocalCacheService {
  final SharedPreferences _prefs;

  LocalCacheServiceImpl(this._prefs);

  @override
  Future<bool> setString({
    required String key,
    required String value,
  }) async {
   return await _prefs.setString(key, value);
  }

  @override
  Future<String?> getString({
    required String key,
  }) async {
    return _prefs.getString(key);
  }

  @override
  Future<bool> setBool({
    required String key,
    required bool value,
  }) async {
   return await _prefs.setBool(key, value);
  }

  @override
  Future<bool?> getBool({
    required String key,
  }) async {
    return _prefs.getBool(key);
  }

  @override
  Future<bool> setInt({
    required String key,
    required int value,
  }) async {
   return await _prefs.setInt(key, value);
  }

  @override
  Future<int?> getInt({
    required String key,
  }) async {
    return _prefs.getInt(key);
  }

  @override
  Future<bool> setStringList({
    required String key,
    required List<String> value,
  }) async {
 return   await _prefs.setStringList(key, value);
  }

  @override
  Future<List<String>?> getStringList({
    required String key,
  }) async {
    return _prefs.getStringList(key);
  }

  @override
  Future<bool> remove({
    required String key,
  }) async {
   return await _prefs.remove(key);
  }

  @override
  Future<bool> clear() async {
   return await _prefs.clear();
  }
}
