import 'dart:convert';

import '../../domain/entities/message.dart';
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
      payload: utf8.encode(_identityManager.localIdentity.displayName),
      messageId: ''
    );
    _connectionManager.sendBytes(endpointId, packet);
  }

  void handleHandshake(Packet packet) {
    final peerName = utf8.decode(packet.payload);
    if (peerName.isEmpty) return;

    _connectionManager.updateUuidMapping(
      uuid: packet.senderUserId,
      name: peerName,
    );
  }
}
