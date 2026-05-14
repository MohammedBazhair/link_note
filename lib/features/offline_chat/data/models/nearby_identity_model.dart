import 'dart:convert';

import '../../domain/entities/nearby_identity.dart';

class NearbyIdentityModel extends NearbyIdentity {
  NearbyIdentityModel({
    required super.uuid,
    required super.displayName,
  });

  factory NearbyIdentityModel.fromMap(Map<String, dynamic> map) {
    return NearbyIdentityModel(
      uuid: map['u'] ?? 'unknown',
      displayName: map['n'] ?? 'غير معروف',
    );
  }

  factory NearbyIdentityModel.fromJson(String source) {
    final map = json.decode(source);
    return NearbyIdentityModel.fromMap(map);
  }

  NearbyIdentityModel copyWith({
    String? uuid,
    String? displayName,
  }) {
    return NearbyIdentityModel(
      uuid: uuid ?? this.uuid,
      displayName: displayName ?? this.displayName,
    );
  }

  Map<String, dynamic> toMap() {
    return {'u': uuid, 'n': displayName};
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'NearbyIdentity(uuid: $uuid, name: $displayName)';
}
