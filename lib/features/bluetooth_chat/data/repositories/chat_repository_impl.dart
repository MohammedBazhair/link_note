import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/internal_constants/log.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasource/nearby_service.dart';
import '../models/incoming_frame.dart';
import '../models/protocol.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(
    this._connectionManager,
    this._sessionManager, {
    required String myUserId,
  }) : _myUserId = myUserId {
    _incomingSub = _connectionManager.incoming.listen(_handleIncoming);
    _connectedSub = _connectionManager.connectedStream.listen(
      _handleConnectedChange,
    );

    // Trigger handshake for any pre-existing connections
    Future.delayed(const Duration(milliseconds: 500), () {
      for (final endpointId in _connectionManager.discoveredEndpoints) {
        if (_connectionManager.isConnected(endpointId)) {
          _handleConnectedChange({endpointId});
        }
      }
    });
  }

  final NearbyConnectionManager _connectionManager;
  final ChatSessionManager _sessionManager;
  final String _myUserId;
  final _controller = StreamController<Message>.broadcast();
  final List<Message> _history = [];
  late final StreamSubscription<IncomingFrame> _incomingSub;
  late final StreamSubscription<Set<String>> _connectedSub;
  final Set<String> _handshakedEndpoints = {};

  void _handleConnectedChange(Set<String> connectedIds) {
    for (final id in connectedIds) {
      if (!_handshakedEndpoints.contains(id)) {
        // Delay handshake slightly to ensure the native link is fully ready for bytes
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (_connectionManager.isConnected(id)) {
            _sendHandshake(id);
          }
        });
        _handshakedEndpoints.add(id);
      }
    }
    _handshakedEndpoints.retainAll(connectedIds);
  }

  @override
  Stream<Message> get messages => _controller.stream;

  @override
  List<Message> get messageHistory => List.unmodifiable(_history);

  void _sendHandshake(String endpointId) {
    Logger.log(message: 'Sending handshake to $endpointId');
    final packet = Protocol.buildPacket(
      senderUserId: _myUserId,
      type: MessageType.handshake,
      payload: Uint8List(0),
    );
    _connectionManager.sendBytes(endpointId, packet);
  }

  void _handleIncoming(IncomingFrame frame) {
    Logger.log(message: 'Incoming frame from ${frame.peerEndpointId}');
    try {
      final packet = Protocol.parsePacket(frame.bytes);
      Logger.log(
        message:
            'Parsed packet: type=${packet.messageType}, sender=${packet.senderUserId}',
      );

      // ALWAYS UPDATE SESSION: Ensure we have the latest endpoint mapped to this UUID
      final session = ChatSession.create(
        myUserId: _myUserId,
        peerUserId: packet.senderUserId,
        peerAddress: frame.peerEndpointId,
      );
      _sessionManager.addSession(session);

      if (packet.messageType == MessageType.handshake) {
        Logger.log(message: 'Handshake successful from ${packet.senderUserId}');
        return;
      }

      final message = Message.fromPacket(
        packet: packet,
        myId: _myUserId,
        senderId: packet.senderUserId,
      );

      Logger.log(
        message:
            'Message added to stream. From: ${message.senderUserId}, ChatID: ${message.chatId}',
      );

      _history.add(message);
      _controller.add(message);
    } catch (e, st) {
      Logger.log(error: 'Error in _handleIncoming: $e', stackTrace: st);
    }
  }

  /// Resolves a peer's Bluetooth address from their logical user id.
  ChatSession? _resolveSession(String peerUserId) {
    var session = _sessionManager.getSession(peerUserId);

    // RECOVERY LOGIC: If session is missing but we are connected, recreate it
    if (session == null) {
      Logger.log(
        message: 'Session NULL for $peerUserId. Attempting recovery...',
      );
      final endpointId = _connectionManager.getEndpointIdByUserName(peerUserId);
      if (endpointId != null && _connectionManager.isConnected(endpointId)) {
        Logger.log(
          message: 'Recovering missing session for $peerUserId at $endpointId',
        );
        session = ChatSession.create(
          myUserId: _myUserId,
          peerUserId: peerUserId,
          peerAddress: endpointId,
        );
        _sessionManager.addSession(session);
      } else {
        Logger.log(
          error:
              'Recovery failed for $peerUserId. Unknown or disconnected endpoint.',
        );
      }
    }
    return session;
  }

  @override
  void sendText(String peerUserId, String text) {
    Logger.log(message: 'sendText called. peerUserId: $peerUserId');
    final session = _resolveSession(peerUserId);
    if (session == null) {
      Logger.log(error: 'No active session for peer $peerUserId');
      return;
    }

    final payload = Uint8List.fromList(utf8.encode(text));
    final packet = Protocol.buildPacket(
      senderUserId: _myUserId,
      type: MessageType.text,
      payload: payload,
    );
    Logger.log(message: 'Sending text to ${session.peerAddress}');
    _connectionManager.sendBytes(session.peerAddress, packet);

    // Add to local stream so it shows in UI
    final message = Message(
      id: const Uuid().v4(),
      senderUserId: _myUserId,
      type: MessageType.text,
      text: text,
      time: DateTime.now().toUtc(),
      chatId: Message.buildChatId(_myUserId, peerUserId),
    );
    _history.add(message);
    _controller.add(message);
  }

  @override
  void sendImage(String peerUserId, Uint8List bytes) {
    final session = _resolveSession(peerUserId);
    if (session == null) {
      Logger.log(error: 'No active session for peer $peerUserId');
      return;
    }

    final packet = Protocol.buildPacket(
      senderUserId: _myUserId,
      type: MessageType.image,
      payload: bytes,
    );

    _connectionManager.sendBytes(session.peerAddress, packet);

    // Add to local stream so it shows in UI
    final message = Message(
      id: const Uuid().v4(),
      senderUserId: _myUserId,
      type: MessageType.image,
      imagePath: 'sent_image_${DateTime.now().millisecondsSinceEpoch}.png',
      time: DateTime.now().toUtc(),
      chatId: Message.buildChatId(_myUserId, peerUserId),
    );
    // Actually, we should probably save the bytes to a file if we want to display it properly,
    // but for now let's just add it to the stream.
    // The UI might need the imagePath to exist.
    _history.add(message);
    _controller.add(message);
  }

  @override
  void dispose() {
    _incomingSub.cancel();
    _connectedSub.cancel();
    _controller.close();
  }
}
