import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../../../../core/constants/internal_constants/log.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasource/bluetooth_service.dart';
import '../models/protocol.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(
    this._connectionManager,
    this._sessionManager, {
    required String myUserId,
  }) : _myUserId = myUserId {
    _connectionManager.incoming.listen(_handleIncoming);
  }

  final BluetoothConnectionManager _connectionManager;
  final ChatSessionManager _sessionManager;
  final String _myUserId;
  final _controller = StreamController<Message>.broadcast();

  @override
  Stream<Message> get messages => _controller.stream;

  void _handleIncoming(IncomingFrame frame) {
    try {
      final packet = Protocol.parsePacket(frame.bytes);

      final message = Message.fromPacket(
        packet: packet,
        myId: _myUserId,
        senderId: packet.senderUserId,
      );

      _controller.add(message);
    } catch (e, st) {
      Logger.log(error: e, stackTrace: st);
    }
  }

  /// Resolves a peer's Bluetooth address from their logical user id.
  ChatSession? _resolveSession(String peerUserId) {
    return _sessionManager.getSession(peerUserId);
  }

  @override
  void sendText(String peerUserId, String text) {
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
    _connectionManager.send(session.peerAddress, packet);
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

    _connectionManager.send(session.peerAddress, packet);
  }

  @override
  void dispose() {
    _controller.close();
  }
}
