import 'dart:convert';
import 'dart:typed_data';

import 'package:link_note/features/offline_chat/domain/entities/message_type.dart';
import 'package:link_note/features/offline_chat/domain/entities/reaction_emoji.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/internal_constants/log.dart';
import '../../domain/entities/message.dart';
import '../models/protocol.dart';
import '../services/chat_session_manager.dart';
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
    String? replyToMessageId,
  }) async {
    final session = _sessionManager.resolveSession(peerUserId);
    if (session == null) return null;

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
      replyToMessageId: replyToMessageId,
    );

    final packet = Protocol.buildPacket(
      senderUserId: _identityManager.localIdentity.uuid,
      type: MessageType.text,
      payload: Uint8List.fromList(utf8.encode(text)),
      messageId: message.id,
      replyToMessageId: replyToMessageId,
    );

    Logger.log(
      message: 'Sending text to ${session.peerAddress} id=${message.id}',
    );

    final sent = await _connectionManager.sendBytes(
      session.peerAddress,
      packet,
    );

    if (!sent) {
      // Sending failed - return null so repository won't mark message as sent
      return null;
    }

    return message;
  }

  Future<Message?> sendImage({
    required String peerUserId,
    required String filePath,
    String? replyToMessageId,
  }) async {
    final session = _sessionManager.resolveSession(peerUserId);
    if (session == null) return null;

    final payloadId = await _connectionManager.sendFile(
      endpointId: session.peerAddress,
      filePath: filePath,
    );

    if (payloadId == null) return null;

    final message = Message(
      id: const Uuid().v4(),
      senderUserId: _identityManager.localIdentity.uuid,
      type: MessageType.image,
      filePath: filePath,
      time: DateTime.now().toUtc(),
      chatId: Message.buildChatId(
        _identityManager.localIdentity.uuid,
        peerUserId,
      ),
      replyToMessageId: replyToMessageId,
    );

    final metadataPacket = Protocol.buildPacket(
      senderUserId: _identityManager.localIdentity.uuid,
      type: MessageType.image,
      payload: Uint8List.fromList(utf8.encode('$payloadId')),
      messageId: message.id,
      replyToMessageId: replyToMessageId,
    );

    await _connectionManager.sendBytes(session.peerAddress, metadataPacket);

    return message;
  }

  Future<Message?> sendVoiceRecord({
    required String peerUserId,
    required String filePath,
    String? replyToMessageId,
  }) async {
    final session = _sessionManager.resolveSession(peerUserId);
    if (session == null) return null;

    // A small delay to ensure the recorder has fully closed and released the file
    await Future.delayed(const Duration(milliseconds: 200));

    final payloadId = await _connectionManager.sendFile(
      endpointId: session.peerAddress,
      filePath: filePath,
    );

    if (payloadId == null) return null;

    final message = Message(
      id: const Uuid().v4(),
      senderUserId: _identityManager.localIdentity.uuid,
      type: MessageType.voice,
      filePath: filePath,
      time: DateTime.now().toUtc(),
      chatId: Message.buildChatId(
        _identityManager.localIdentity.uuid,
        peerUserId,
      ),
      replyToMessageId: replyToMessageId,
    );

    final metadataPacket = Protocol.buildPacket(
      senderUserId: _identityManager.localIdentity.uuid,
      type: MessageType.voice,
      payload: Uint8List.fromList(utf8.encode('$payloadId')),
      messageId: message.id,
      replyToMessageId: replyToMessageId,
    );

    await _connectionManager.sendBytes(session.peerAddress, metadataPacket);

    return message;
  }

  Future<Message?> sendReactionEmoji({
    required String peerUserId,
    ReactionEmoji? reactionEmoji,
    required String messageId,
  }) async {
    final session = _sessionManager.resolveSession(peerUserId);
    if (session == null) return null;

    final message = Message(
      id: messageId,
      senderUserId: _identityManager.localIdentity.uuid,
      type: MessageType.reactionEmoji,
      time: DateTime.now().toUtc(),
      chatId: Message.buildChatId(
        _identityManager.localIdentity.uuid,
        peerUserId,
      ),
      reactionEmoji: reactionEmoji,
    );

    final payload = Uint8List(4);
    ByteData.sublistView(payload).setUint32(0, reactionEmoji?.code ?? 0);
    
    final packet = Protocol.buildPacket(
      senderUserId: _identityManager.localIdentity.uuid,
      type: MessageType.reactionEmoji,
      payload:payload,
      messageId: messageId,
    );

    final sent = await _connectionManager.sendBytes(
      session.peerAddress,
      packet,
    );

    if (!sent) {
      // Sending failed - return null so repository won't mark message as sent
      return null;
    }

    return message;
  }
}
