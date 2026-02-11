import 'dart:convert';

import '../../domain/entities/chat_session.dart';
import '../../domain/entities/message.dart';
import '../models/incoming_frame.dart';
import '../models/packet.dart';
import '../services/chat_session_manager.dart';
import '../services/nearby_identity_manager.dart';
import 'image_transfer_handler.dart';
import 'voice_transfer_handler.dart';

class IncomingMessageHandler {
  IncomingMessageHandler(
    this._sessionManager,
    this._identityManager,
    this._imageHandler,
    this._voiceHandler,
  );

  final ChatSessionManager _sessionManager;
  final NearbyIdentityManager _identityManager;
  final ImageTransferHandler _imageHandler;
  final VoiceTransferHandler _voiceHandler;

  Message? handlePacket(IncomingFrame frame, Packet packet) {
    final session = ChatSession.create(
      myUserId: _identityManager.localIdentity.uuid,
      peerUserId: packet.senderUserId,
      peerAddress: frame.peerEndpointId,
    );

    _sessionManager.addSession(session);

    switch (packet.messageType) {
      case MessageType.handshake:
        return null;
      case MessageType.text:
        return Message.fromPacket(
          packet: packet,
          myId: _identityManager.localIdentity.uuid,
          senderId: packet.senderUserId,
        );
      case MessageType.image:
        final payloadId = int.tryParse(utf8.decode(packet.payload));
        if (payloadId != null) {
          _imageHandler.registerIncomingImage(payloadId, packet.senderUserId);
        }
        return null;
      case MessageType.voice:
        final payloadId = int.tryParse(utf8.decode(packet.payload));
        if (payloadId != null) {
          return _voiceHandler.registerIncomingVoice(
            payloadId: payloadId,
            senderId: packet.senderUserId,
            myUserId: _identityManager.localIdentity.uuid,
            messageId: packet.messageId,
            replyToMessageId: packet.replyToMessageId,
          );
        }
        return null;
    }
  }
}
