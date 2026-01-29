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
    final userIdLength = userIdBytes.length;

    if (userIdLength > 255) {
      throw Exception('UserId too long');
    }

    final lengthBytes = ByteData(_lengthFieldBytes)
      ..setUint32(0, payload.length);

    final buffer = BytesBuilder();
    buffer.addByte(userIdLength); // [1 byte] userId length
    buffer.add(userIdBytes); // [N bytes] userId
    buffer.addByte(type.typeCode); // [1 byte] type
    buffer.add(lengthBytes.buffer.asUint8List()); // [4 bytes] payload length
    buffer.add(payload); // [N bytes] payload

    return buffer.toBytes();
  }

  /// Reads header + payload from a fully assembled frame.
  static Packet parsePacket(Uint8List data) {
    if (data.isEmpty) {
      throw Exception('Empty data');
    }

    var offset = 0;

    final userIdLength = data[offset];
    offset += 1;

    if (data.length < offset + userIdLength + 1 + _lengthFieldBytes) {
      throw Exception('Packet too short for header');
    }

    final userIdBytes = data.sublist(offset, offset + userIdLength);
    final senderUserId = utf8.decode(userIdBytes);
    offset += userIdLength;

    final typeValue = data[offset];
    offset += 1;

    final lengthView = ByteData.sublistView(
      data,
      offset,
      offset + _lengthFieldBytes,
    );
    final payloadLength = lengthView.getUint32(0);
    offset += _lengthFieldBytes;

    if (data.length < offset + payloadLength) {
      throw Exception(
        'Incomplete packet payload: expected $payloadLength more bytes',
      );
    }

    final payload = data.sublist(offset, offset + payloadLength);

    return Packet(
      senderUserId: senderUserId,
      messageType: MessageType.fromValue(typeValue),
      payload: payload,
    );
  }
}
