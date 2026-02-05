import 'dart:typed_data';

import '../models/nearby_identity_model.dart';

/// Manages local user identity and avatar updates
class NearbyIdentityManager {
  NearbyIdentityManager(this._localIdentity);

  NearbyIdentityModel _localIdentity;

  NearbyIdentityModel get localIdentity => _localIdentity;

  void updateLocalName(String newName) {
    _localIdentity = _localIdentity.copyWith(displayName: newName);
  }

  void updateAvatar(Uint8List avatarBytes) {
    _localIdentity = _localIdentity.copyWith(avatarBytes: avatarBytes);
  }
}
