import 'dart:convert';

import '../../domain/entities/message.dart';
import '../models/nearby_identity_model.dart';
import '../models/packet.dart';
import '../models/protocol.dart';
import '../services/nearby_connection_manager.dart';
import '../services/nearby_identity_manager.dart';

class ChatHandshakeHandler {
  ChatHandshakeHandler(this._connectionManager, this._identityManager);

  final NearbyConnectionManager _connectionManager;
  final NearbyIdentityManager _identityManager;

  void sendHandshake(String endpointId) {
    final packet = Protocol.buildPacket(
      senderUserId: _identityManager.localIdentity.uuid,
      type: MessageType.handshake,
      payload: utf8.encode(_identityManager.localIdentityJson),
      messageId: '',
    );
    _connectionManager.sendBytes(endpointId, packet);
  }

  void handleHandshake(Packet packet) {
    try {
      final jsonStr = utf8.decode(packet.payload);
      if (jsonStr.isEmpty) return;

      final identity = NearbyIdentityModel.fromJson(jsonStr);
      _connectionManager.updateIdentity(identity);
    } catch (e) {
      // Fallback or ignore malformed handshake
    }
  }
}
