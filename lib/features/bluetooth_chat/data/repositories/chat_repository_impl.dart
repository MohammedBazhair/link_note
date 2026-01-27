import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../../../../core/constants/internal_constants/log.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../bluetooth/bluetooth_service.dart';
import '../bluetooth/protocol.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._service, {required String myUserId})
    : _myUserId = myUserId {
    _service.incoming.listen(_handleIncoming);
  }
  final BluetoothService _service;
  final String _myUserId;
  final _controller = StreamController<Message>.broadcast();

  /// peerId -> userId
  final Map<String, String> _peerToUser = {};

  /// userId -> peerId
  final Map<String, String> _userToPeer = {};

  @override
  Stream<Message> get messages => _controller.stream;

  void _handleIncoming(Map<String, Uint8List> event) {
    event.forEach((peerId, rawData) {
      try {
        final packet = Protocol.parsePacket(rawData);

        final message = Message.fromPacket(
          packet: packet,
          myId: _myUserId,
          senderId: peerId,
        );

        _controller.add(message);
      } catch (e) {
        Logger.log(error: e);
      }
    });
  }

  @override
  Future<void> sendText(String peerId, String text) async {
    final payload = Uint8List.fromList(utf8.encode(text));
    final packet = Protocol.buildPacket(senderUserId: _myUserId, type: MessageType.text, payload: payload);
    _service.send(peerId, packet);
  }

  @override
  Future<void> sendImage(String peerId, Uint8List bytes) async {
    final packet = Protocol.buildPacket(
      senderUserId: _myUserId,
      type: MessageType.image,
      payload: bytes,
    );

    _service.send(peerId, packet);
  }

   @override
     void dispose() {
    _controller.close();
  }
}
