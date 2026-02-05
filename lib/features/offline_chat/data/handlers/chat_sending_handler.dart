import 'dart:convert';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../../domain/entities/chat_session.dart';
import '../../domain/entities/message.dart';
import '../models/protocol.dart';
import '../services/nearby_connection_manager.dart';
import '../services/nearby_identity_manager.dart';

class ChatSendingHandler {
  ChatSendingHandler(
    this._connectionManager,
    this._sessionManager,
    this._identityManager,
  );

  final NearbyConnectionManager _connectionManager;
  final ChatSessionManager _sessionManager;
  final NearbyIdentityManager _identityManager;

  Future<Message?> sendText({
    required String peerUserId,
    required String text,
  }) async {
    final session = _sessionManager.resolveSession(peerUserId);
    if (session == null) return null;

    final packet = Protocol.buildPacket(
      senderUserId: _identityManager.localIdentity.uuid,
      type: MessageType.text,
      payload: Uint8List.fromList(utf8.encode(text)),
    );

    await _connectionManager.sendBytes(session.peerAddress, packet);

    final message = Message(
      id: const Uuid().v4(),
      senderUserId: _identityManager.localIdentity.uuid,
      type: MessageType.text,
      text: text,
      time: DateTime.now().toUtc(),
      chatId: Message.buildChatId(
        _identityManager.localIdentity.uuid,
        peerUserId,
      ),
    );

    return message;
  }

  Future<Message?> sendImage({
    required String peerUserId,
    required String filePath,
  }) async {
    final session = _sessionManager.resolveSession(peerUserId);
    if (session == null) return null;

    final payloadId = await _connectionManager.sendFile(
      endpointId: session.peerAddress,
      filePath: filePath,
    );

    if (payloadId == null) return null;

    final metadataPacket = Protocol.buildPacket(
      senderUserId: _identityManager.localIdentity.uuid,
      type: MessageType.image,
      payload: Uint8List.fromList(utf8.encode('$payloadId')),
    );

    await _connectionManager.sendBytes(session.peerAddress, metadataPacket);

    final message = Message(
      id: const Uuid().v4(),
      senderUserId: _identityManager.localIdentity.uuid,
      type: MessageType.image,
      imagePath: filePath,
      time: DateTime.now().toUtc(),
      chatId: Message.buildChatId(
        _identityManager.localIdentity.uuid,
        peerUserId,
      ),
    );

    return message;
  }
}
