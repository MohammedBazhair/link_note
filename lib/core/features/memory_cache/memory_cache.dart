import '../../constants/internal_constants/log.dart';

class MemoryCache {
  final Map<String, dynamic> _cache = {};

  T? get<T>(String key) {
    try {
      return _cache[key];
    } catch (e) {
      return null;
    }
  }

  void set(String key, dynamic value) {
    try {
      _cache[key] = value;
    } catch (e) {
      Logger.log(error: e);
    }
  }

  void remove(String key) {
    _cache.remove(key);
  }
}
