import 'dart:async';

import 'package:link_note/features/offline_chat/domain/entities/reaction_emoji.dart';

import '../../../../core/constants/internal_constants/log.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../presentation/controllers/chat_state.dart';
import '../handlers/chat_handshake_handler.dart';
import '../handlers/chat_sending_handler.dart';
import '../handlers/image_transfer_handler.dart';
import '../handlers/incoming_message_handler.dart';
import '../handlers/voice_transfer_handler.dart';
import '../models/incoming_frame.dart';
import '../models/protocol.dart';
import '../services/chat_session_manager.dart';
import '../services/nearby_connection_manager.dart';
import '../services/nearby_identity_manager.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(
    this._connectionManager,
    this._sessionManager,
    this._identityManager,
    this._sendingHandler,
    this._handshakeHandler,
    this._imageHandler,
    this._voiceHandler,
    this._incomingHandler,
  ) {
    _incomingSub = _connectionManager.incomingFrames.listen(_handleIncoming);

    _connectedSub = _connectionManager.connectedEndpointsStream.listen(
      _handleConnectedChange,
    );

    // Handshake recovery for already-connected peers
    _recoverHandshakes();
  }

  final NearbyConnectionManager _connectionManager;
  final ChatSessionManager _sessionManager;
  final NearbyIdentityManager _identityManager;
  final ChatSendingHandler _sendingHandler;

  final ChatHandshakeHandler _handshakeHandler;
  final ImageTransferHandler _imageHandler;
  final VoiceTransferHandler _voiceHandler;
  final IncomingMessageHandler _incomingHandler;

  final _controller = StreamController<Message>.broadcast();
  final Map<String, ChatRoom> _history = {};
  final Set<String> _myChatFriendsIds = {};

  late final StreamSubscription<IncomingFrame> _incomingSub;
  late final StreamSubscription<Set<String>> _connectedSub;

  final Set<String> _handshakedEndpoints = {};
  final Map<String, Timer?> _handshakeTimers = {};

  @override
  Stream<Message> get messages => _controller.stream;

  @override
  Map<String, ChatRoom> get chatsHistory => Map.unmodifiable(_history);

  @override
  Set<String> myChatFriendsIds(String? myUserId) {
    return _myChatFriendsIds..remove(myUserId);
  }

  Future<void> _recoverHandshakes() async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (final endpointId in _connectionManager.knownEndpointIds) {
      if (_connectionManager.isConnected(endpointId)) {
        _handleConnectedChange({endpointId});
      }
    }
  }

  void _handleConnectedChange(Set<String> connectedIds) {
    for (final endpointId in connectedIds) {
      if (_handshakedEndpoints.contains(endpointId)) continue;
      if (_handshakeTimers.containsKey(endpointId)) continue;

      _handshakeTimers[endpointId] = Timer(
        const Duration(milliseconds: 1500),
        () {
          if (_connectionManager.isConnected(endpointId)) {
            _handshakeHandler.sendHandshake(endpointId);
            _handshakedEndpoints.add(endpointId);
          }
          _handshakeTimers.remove(endpointId);
        },
      );
    }

    // Cancel timers for disconnected endpoints
    final disconnected = _handshakeTimers.keys
        .where((id) => !connectedIds.contains(id))
        .toList();

    for (final id in disconnected) {
      _handshakeTimers[id]?.cancel();
      _handshakeTimers.remove(id);
      _handshakedEndpoints.remove(id);
    }
  }

  void _handleIncoming(IncomingFrame frame) {
    Logger.log(
      message:
          'Incoming frame from ${frame.peerEndpointId} payloadId=${frame.payloadId} filePath=${frame.filePath} bytes=${frame.bytes?.length} messageId=${frame.messageId}',
    );
    // 1️⃣ File payload completion
    if (frame.payloadId != null && frame.filePath != null) {
      // mark completion for both image and voice handlers; the correct
      // handler will build the message if this payload corresponds to it.
      _imageHandler.markFileCompleted(frame.payloadId!, frame.filePath!);
      _voiceHandler.markFileCompleted(frame.payloadId!, frame.filePath!);

      final imageMessage = _imageHandler.tryBuildImageMessage(
        payloadId: frame.payloadId!,
        myUserId: _identityManager.localIdentity.uuid,
      );

      if (imageMessage != null) {
        _addMessageToHistory(imageMessage);
        _controller.add(imageMessage);
        return;
      }

      final voiceMessage = _voiceHandler.tryBuildVoiceMessage(
        payloadId: frame.payloadId!,
        myUserId: _identityManager.localIdentity.uuid,
      );

      if (voiceMessage != null) {
        Logger.log(
          message:
              'Built voice message id=${voiceMessage.id} from payload ${frame.payloadId}',
        );
        _addMessageToHistory(voiceMessage);
        _controller.add(voiceMessage);
        return;
      }
      return;
    }

    // 2️⃣ Bytes payload
    if (frame.bytes == null) {
      Logger.log(
        message:
            'Frame bytes null for payloadId=${frame.payloadId} from ${frame.peerEndpointId}',
      );
      return;
    }

    try {
      final packet = Protocol.parsePacket(frame.bytes!);
      Logger.log(
        message:
            'Parsed Packet sender=${packet.senderUserId} id=${packet.messageId} type=${packet.messageType}',
      );

      // Handshake packets are handled separately
      if (packet.messageType == MessageType.handshake) {
        _handshakeHandler.handleHandshake(packet);
        return;
      }

      // Delegate message logic
      final message = _incomingHandler.handlePacket(frame, packet);

      if (message != null) {
        Logger.log(
          message:
              'Incoming message built id=${message.id} chatId=${message.chatId} from=${message.senderUserId}',
        );
      }

      if (message != null) {
        _addMessageToHistory(message);

        _controller.add(message);
      }
    } catch (e, st) {
      Logger.log(error: 'Failed to handle incoming frame: $e', stackTrace: st);
    }
  }

  void _addMessageToHistory(Message message) {
    _history.update(
      message.chatId,
      (chatRoom) => chatRoom.copyWith(
        messages: {...chatRoom.messages, message.id: message},
        lastUpdated: message.time,
      ),
      ifAbsent: () =>
          ChatRoom(messages: {message.id: message}, lastUpdated: message.time),
    );
    _myChatFriendsIds.add(message.senderUserId);
  }

  @override
  void dispose() {
    _incomingSub.cancel();
    _connectedSub.cancel();
    _controller.close();
  }

  @override
  Future<void> sendText({
    required String peerUserId,
    required String text,
    String? replyToMessageId,
  }) async {
    final message = await _sendingHandler.sendText(
      peerUserId: peerUserId,
      text: text,
      replyToMessageId: replyToMessageId,
    );

    if (message == null) return;

    _addMessageToHistory(message);

    _controller.add(message);
  }

  @override
  Future<void> sendImage({
    required String peerUserId,
    required String filePath,
    String? replyToMessageId,
  }) async {
    final message = await _sendingHandler.sendImage(
      peerUserId: peerUserId,
      filePath: filePath,
      replyToMessageId: replyToMessageId,
    );

    if (message == null) return;

    _addMessageToHistory(message);
    _controller.add(message);
  }

  @override
  void sendVoiceRecord({
    required String peerUserId,
    required String filePath,
    String? replyToMessageId,
  }) async {
    final message = await _sendingHandler.sendVoiceRecord(
      peerUserId: peerUserId,
      filePath: filePath,
      replyToMessageId: replyToMessageId,
    );

    if (message == null) return;

    _addMessageToHistory(message);
    _controller.add(message);
  }

  @override
  void sendEmoji({
    required String peerUserId,
     ReactionEmoji? reactionEmoji,
    required String messageId,
  }) async {
  final message=  await _sendingHandler.sendReactionEmoji(
      peerUserId: peerUserId,
      reactionEmoji: reactionEmoji,
      messageId: messageId,
    );

      if (message == null) return;

    _addMessageToHistory(message);
    _controller.add(message);
  }
}
