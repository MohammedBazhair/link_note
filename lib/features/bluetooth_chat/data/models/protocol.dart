import 'dart:convert';
import 'dart:typed_data';

import '../../domain/entities/message.dart';
import 'packet.dart';

/// Protocol-level encoder/decoder for chat packets.
///
/// Wire format (big-endian):
/// [36 bytes] UTF8 senderUserId (UUID v4)
/// [1 byte ]  messageType
/// [4 bytes]  payloadLength (uint32)
/// [N bytes]  payload
class Protocol {
  static const _userIdLength = 36; // (UUID v4 utf8)
  static const _lengthFieldBytes = 4;

  static Uint8List buildPacket({
    required String senderUserId,
    required MessageType type,
    required Uint8List payload,
  }) {
    final userIdBytes = utf8.encode(senderUserId);

    if (userIdBytes.length != _userIdLength) {
      throw Exception('Invalid UUID length');
    }

    final lengthBytes = ByteData(_lengthFieldBytes)
      ..setUint32(0, payload.length);

    final buffer = BytesBuilder();
    buffer.add(userIdBytes); // [36 bytes] userId
    buffer.addByte(type.typeCode); // [1 byte] type
    buffer.add(lengthBytes.buffer.asUint8List()); // [4 bytes] payload length
    buffer.add(payload); // [N bytes] payload

    return buffer.toBytes();
  }

  /// Reads header + payload from a fully assembled frame.
  static Packet parsePacket(Uint8List data) {
    const minimumLength = _userIdLength + 1 + _lengthFieldBytes;
    if (data.length < minimumLength) {
      throw Exception('Invalid packet');
    }

    var offset = 0;

    final userIdBytes = data.sublist(offset, _userIdLength);
    final senderUserId = utf8.decode(userIdBytes);
    offset += _userIdLength;

    final type = data[offset];
    offset += 1;

    final lengthView = ByteData.sublistView(
      data,
      offset,
      offset + _lengthFieldBytes,
    );
    final payloadLength = lengthView.getUint32(0);
    offset += _lengthFieldBytes;

    if (data.length < minimumLength + payloadLength) {
      throw Exception('Incomplete packet payload');
    }

    final payload = data.sublist(offset, offset + payloadLength);

    return Packet(
      senderUserId: senderUserId,
      messageType: MessageType.fromValue(type),
      payload: payload,
    );
  }
}
