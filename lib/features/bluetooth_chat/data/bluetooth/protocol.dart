import 'dart:convert';
import 'dart:typed_data';

import '../../domain/entities/message.dart';
import 'packet.dart';

class Protocol {
  // [ userId | messageType | payload ]

  // [36 bytes]  userId
  // [1 byte ]   messageType
  // [m bytes]   payload

  static const _userIdLength = 36; // (UUID v4 utf8)

  static Uint8List buildPacket({
    required String senderUserId,
    required MessageType type,
    required Uint8List payload,
  }) {
    final userIdBytes = utf8.encode(senderUserId);

    if (userIdBytes.length != _userIdLength) {
      throw Exception('senderUserId must be UUID v4 (36 chars)');
    }

    final buffer = BytesBuilder();
    buffer.add(userIdBytes);

    /// [36 bytes] userId
    buffer.addByte(type.typeCode);

    /// [1 byte] messageType
    buffer.add(payload);

    /// [m bytes] payload

    return buffer.toBytes();
  }

  // قراءة Header + Payload
  static Packet parsePacket(Uint8List data) {
    if (data.length < _userIdLength + 1) {
      throw Exception('Invalid packet');
    }

    int offset = 0;
    final userId = utf8.decode(data.sublist(offset, offset + _userIdLength));

    offset += _userIdLength;

    final type = data[offset];

    offset++;

    final payload = data.sublist(offset);

    return Packet.from(typeCode: type, payload: payload, senderUserId: userId);
  }
}
