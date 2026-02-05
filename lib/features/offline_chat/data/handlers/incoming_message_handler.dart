import 'dart:convert';

import '../../domain/entities/chat_session.dart';
import '../../domain/entities/message.dart';
import '../models/incoming_frame.dart';
import '../models/packet.dart';
import '../services/nearby_identity_manager.dart';
import 'image_transfer_handler.dart';

class IncomingMessageHandler {
  IncomingMessageHandler(
    this._sessionManager,
    this._identityManager,
    this._imageHandler,
  );

  final ChatSessionManager _sessionManager;
  final NearbyIdentityManager _identityManager;
  final ImageTransferHandler _imageHandler;

  Message? handlePacket(IncomingFrame frame, Packet packet) {
    final session = ChatSession.create(
      myUserId: _identityManager.localIdentity.uuid,
      peerUserId: packet.senderUserId,
      peerAddress: frame.peerEndpointId,
    );

    _sessionManager.addSession(session);

    if (packet.messageType == MessageType.text) {
      return Message.fromPacket(
        packet: packet,
        myId: _identityManager.localIdentity.uuid,
        senderId: packet.senderUserId,
      );
    }

    if (packet.messageType == MessageType.image) {
      final payloadId = int.tryParse(utf8.decode(packet.payload));
      if (payloadId != null) {
        _imageHandler.registerIncomingImage(payloadId, packet.senderUserId);
      }
    }

    return null;
  }
}
