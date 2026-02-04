import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../domain/entities/nearby_identity.dart';

class NearbyIdentityModel extends NearbyIdentity {
  NearbyIdentityModel({
    required super.uuid,
    required super.displayName,
     super.avatarBytes,
  });

  factory NearbyIdentityModel.fromMap(Map<String, dynamic> map) {
    final imageBytes =map['a'] != null? base64Decode(map['a']):null;
    return NearbyIdentityModel(
      uuid: map['u'] ?? 'unknown',
      displayName: map['n'] ?? 'غير معروف',
      avatarBytes: imageBytes,
    );
  }

  factory NearbyIdentityModel.fromJson(String source) {
    final map = json.decode(source);
    return NearbyIdentityModel.fromMap(map);
  }

  NearbyIdentityModel copyWith({
    String? uuid,
    String? displayName,
    Uint8List? avatarBytes,
  }) {
    return NearbyIdentityModel(
      uuid: uuid ?? this.uuid,
      displayName: displayName ?? this.displayName,
      avatarBytes: avatarBytes ?? this.avatarBytes,
    );
  }

  Map<String, dynamic> toMap() {
    final imageEncoded = avatarBytes != null? base64Encode(avatarBytes!): null;

    return {'u': uuid, 'n': displayName, 'a': imageEncoded};
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'NearbyIdentity(uuid: $uuid, name: $displayName)';
}
