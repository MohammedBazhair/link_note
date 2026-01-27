import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService {
  final Map<String, BluetoothConnection> _connections = {};
  final Map<String, BytesBuilder> _buffers = {}; // Buffer لكل peer
  final StreamController<Map<String, Uint8List>> _incomingController =
      StreamController.broadcast();

  Stream<Map<String, Uint8List>> get incoming => _incomingController.stream;

  void addConnection(String peerId, BluetoothConnection connection) {
    _connections[peerId] = connection;
    _buffers[peerId] = BytesBuilder();

    connection.input!.listen(
      (data) {
        _buffers[peerId]!.add(data);

        // نفترض أن Packet كامل → نرسل للـ Repository
        final  bufferData = _buffers[peerId]!.toBytes();
        if (bufferData.length >= 5) {
          // أقل طول للheader
          final int payloadLength = ByteData.sublistView(
            bufferData,
            1,
            5,
          ).getUint32(0);
          if (bufferData.length >= payloadLength + 5) {
            final  packet = bufferData.sublist(0, payloadLength + 5);
            _incomingController.add({peerId: packet});
            // إزالة Packet من buffer
            _buffers[peerId] = BytesBuilder()
              ..add(bufferData.sublist(payloadLength + 5));
          }
        }
      },
      onDone: () {
        _connections.remove(peerId);
        _buffers.remove(peerId);
      },
    );
  }

  void send(String peerId, Uint8List data) {
    _connections[peerId]?.output.add(data);
  }

  void sendToAll(Uint8List data) {
    _connections.forEach((peerId, conn) {
      conn.output.add(data);
    });
  }
}
