import 'dart:convert';
import '../../domain/entities/nearby_identity.dart';

class NearbyIdentityModel extends NearbyIdentity {
  NearbyIdentityModel({required super.uuid, required super.displayName});

  factory NearbyIdentityModel.fromMap(Map<String, dynamic> map) {
    return NearbyIdentityModel(
      uuid: map['u'] ?? 'unknown',
      displayName: map['n'] ?? 'غير معروف',
    );
  }

  factory NearbyIdentityModel.fromJson(String source) {
    try {
      if (source.isEmpty) {
        return NearbyIdentityModel(uuid: 'unknown', displayName: 'غير معروف');
      }
      final map = json.decode(source);
      if (map is Map<String, dynamic>) {
        return NearbyIdentityModel.fromMap(map);
      }
    } catch (e) {
      // Fallback for non-JSON or malformed strings
      // If it contains our old separator, use it
      if (source.contains('---')) {
        final parts = source.split('---');
        return NearbyIdentityModel(
          uuid: parts[0],
          displayName: parts.length > 1 ? parts[1] : parts[0],
        );
      }
    }
    // Final fallback: use the source itself as the UUID/Name
    return NearbyIdentityModel(
      uuid: source,
      displayName: 'جهاز قديم ($source)',
    );
  }

  NearbyIdentityModel copyWith({String? uuid, String? displayName}) {
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
