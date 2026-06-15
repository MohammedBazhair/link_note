import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'cache_service_interface.dart';

class SecureCacheServiceImpl implements SecureCacheService {
  SecureCacheServiceImpl(this._secure);
  final FlutterSecureStorage _secure;

  @override
  Future<void> setString({required String key, required String value}) {
    return _secure.write(key: key, value: value);
  }

  @override
  Future<String?> getString({required String key}) => _secure.read(key: key);

  @override
  Future<void> remove({required String key}) => _secure.delete(key: key);

  @override
  Future<void> clear() => _secure.deleteAll();
}
