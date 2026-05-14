import '../../../../core/features/memory_cache/memory_cache.dart';
import '../models/nearby_identity_model.dart';

/// Manages local user identity
class NearbyIdentityManager {
  NearbyIdentityManager(this._localIdentity, this._memoryCache);

  final NearbyIdentityModel _localIdentity;
  final MemoryCache _memoryCache;

  NearbyIdentityModel get localIdentity => _localIdentity;
  String get localIdentityJson => _memoryCache.get<String>('profileJson')?? localIdentity.toJson();
}
