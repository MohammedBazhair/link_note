import 'dart:async';

import '../../../../core/constants/internal_constants/log.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../presentation/controllers/chat_state.dart';
import '../handlers/chat_handshake_handler.dart';
import '../handlers/chat_sending_handler.dart';
import '../handlers/image_transfer_handler.dart';
import '../handlers/incoming_message_handler.dart';
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
  Set<String>  myChatFriendsIds(String? myUserId) {
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
    // 1️⃣ File payload completion
    if (frame.payloadId != null && frame.filePath != null) {
      _imageHandler.markFileCompleted(frame.payloadId!, frame.filePath!);

      final imageMessage = _imageHandler.tryBuildImageMessage(
        payloadId: frame.payloadId!,
        myUserId: _identityManager.localIdentity.uuid,
        messageId: frame.messageId,
        replyToMessageId: frame.replyToMessageId,
      );

      if (imageMessage != null) {
        _addMessageToHistory(imageMessage);

        _controller.add(imageMessage);
      }
      return;
    }

    // 2️⃣ Bytes payload
    if (frame.bytes == null) return;

    try {
      final packet = Protocol.parsePacket(frame.bytes!);

      // Handshake packets are handled separately
      if (packet.messageType == MessageType.handshake) {
        _handshakeHandler.handleHandshake(packet);
        return;
      }

      // Delegate message logic
      final message = _incomingHandler.handlePacket(frame, packet);

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
  Future<void> sendText({
    required String peerUserId,
    required String text,
    String? replyToMessageId,
  }) async {
    final message = await _sendingHandler.sendText(
      peerUserId: peerUserId,
      text: text,
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
    );

    if (message == null) return;

    _addMessageToHistory(message);
    _controller.add(message);
  }

  @override
  void dispose() {
    _incomingSub.cancel();
    _connectedSub.cancel();
    _controller.close();
  }
}
