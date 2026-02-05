import 'dart:convert';
import 'dart:typed_data';

import '../../domain/entities/message.dart';
import 'packet.dart';

/// Protocol-level encoder/decoder for chat packets.
///
/// Wire format (big-endian):
/// [1 byte ]  idLength
/// [n bytes] UTF8 senderUserId (UUID v4)
/// [n bytes] UTF8 messageId (UUID v4)
/// [1 byte ]  messageType
/// [4 bytes]  payloadLength (uint32)
/// [n bytes]  payload (uint32)
class Protocol {
  static const _IdLength = 36; // (UUID v4 utf8)
  static const _idLengthFieldBytes = 4;

  static Uint8List buildPacket({
    required String senderUserId,
    required MessageType type,
    required Uint8List payload,
    required String messageId,
  }) {
    final userIdBytes = utf8.encode(senderUserId);
    final messageIdBytes = utf8.encode(messageId);
    final messageIdLength = messageIdBytes.length;
    final userIdLength = userIdBytes.length;

    if (userIdLength > 255) {
      throw Exception('UserId too long');
    }

    final lengthBytes = ByteData(_idLengthFieldBytes)
      ..setUint32(0, payload.length);

    final buffer = BytesBuilder();
    buffer.addByte(userIdLength); // [1 byte] userId length
    buffer.add(userIdBytes); // [N bytes] userId
    buffer.addByte(messageIdLength); // [1 byte] messageId length
    buffer.add(messageIdBytes); // [N bytes] messageId
    buffer.addByte(type.typeCode); // [1 byte] type
    buffer.add(lengthBytes.buffer.asUint8List()); // [4 bytes] payload length
    buffer.add(payload);

    return buffer.toBytes();
  }

  /// Reads header + payload from a fully assembled frame.
  static Packet parsePacket(Uint8List data) {
    if (data.isEmpty) {
      throw Exception('Empty data');
    }

    var offset = 0;

    final userIdLength  = data[offset++];

    

    final userIdBytes = data.sublist(offset, offset + userIdLength);
    final senderUserId = utf8.decode(userIdBytes);
    offset +=userIdLength;

    final messageIdLength = data[offset++];

    final messageIdBytes = data.sublist(offset, offset + messageIdLength);
    final messageId = utf8.decode(messageIdBytes);
    offset += messageIdLength;

    final typeValue = data[offset];
    offset += 1;

    final lengthView = ByteData.sublistView(
      data,
      offset,
      offset + _idLengthFieldBytes,
    );
    final payloadLength = lengthView.getUint32(0);

    offset += _idLengthFieldBytes;

    final payload = data.sublist(offset, offset + payloadLength);

    return Packet(
      senderUserId: senderUserId,
      messageType: MessageType.fromValue(typeValue),
      payload: payload,
      messageId: messageId
    );
  }
}
