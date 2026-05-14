import 'dart:typed_data';

import '../../../../core/features/memory_cache/memory_cache.dart';
import '../models/nearby_identity_model.dart';

/// Manages local user identity and avatar updates
class NearbyIdentityManager {
  NearbyIdentityManager(this._localIdentity, this._memoryCache);

  NearbyIdentityModel _localIdentity;
  final MemoryCache _memoryCache;

  NearbyIdentityModel get localIdentity => _localIdentity;
  String get localIdentityJson => _memoryCache.get<String>('profileJson')?? localIdentity.toJson();


  void updateAvatar(Uint8List avatarBytes) {
    _localIdentity = _localIdentity.copyWith(avatarBytes: avatarBytes);
  }
}
