import 'dart:typed_data';

class NearbyIdentity {
  NearbyIdentity({required this.uuid, required this.displayName,  this.avatarBytes});
  final String uuid;
  final String displayName;
  final Uint8List? avatarBytes;
}
