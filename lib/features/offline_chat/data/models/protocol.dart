import 'dart:convert';
import 'dart:typed_data';

import '../../../../core/constants/internal_constants/log.dart';
import '../../domain/entities/message.dart';
import 'packet.dart';

/// Binary protocol encoder/decoder for chat messages.
///
/// Wire format (big-endian):
/// ┌──────────────────────────────────────────────┐
/// │ 1 byte   │ senderUserId length               │
/// │ n bytes  │ senderUserId (UTF-8)              │
/// │ 1 byte   │ messageId length                  │
/// │ n bytes  │ messageId (UTF-8)                 │
/// │ 1 byte   │ replyToMessageId length           │
/// │ n bytes  │ replyToMessageId (UTF-8, optional)│
/// │ 1 byte   │ message type                      │
/// │ 4 bytes  │ payload length (uint32)           │
/// │ n bytes  │ payload                           │
/// └──────────────────────────────────────────────┘
class Protocol {
  static const _idLengthFieldBytes = 4;

  /// Serializes a message into a binary packet following the protocol format.
  static Uint8List buildPacket({
    required String senderUserId,
    required MessageType type,
    required Uint8List payload,
    required String messageId,
    String? replyToMessageId,
  }) {
    // Encode variable-length string fields as UTF-8
    final userIdBytes = utf8.encode(senderUserId);
    final messageIdBytes = utf8.encode(messageId);
    final replyBytes = utf8.encode(replyToMessageId ?? '');

    if (userIdBytes.length > 255) {
      throw Exception('UserId too long');
    }

    // Payload length is encoded as a fixed uint32
    final payloadLengthBytes = ByteData(_idLengthFieldBytes)
      ..setUint32(0, payload.length);

    final buffer = BytesBuilder();

    // senderUserId
    buffer.addByte(userIdBytes.length);
    buffer.add(userIdBytes);

    // messageId
    buffer.addByte(messageIdBytes.length);
    buffer.add(messageIdBytes);

    // replyToMessageId (optional)
    buffer.addByte(replyBytes.length);
    buffer.add(replyBytes);

    // message metadata
    buffer.addByte(type.typeCode);
    buffer.add(payloadLengthBytes.buffer.asUint8List());

    // payload
    buffer.add(payload);

    return buffer.toBytes();
  }

  /// Deserializes a binary packet into a [Packet] object.
  ///
  /// Throws if the packet is malformed or incomplete.
  static Packet parsePacket(Uint8List data) {
    try {
      if (data.isEmpty) {
        throw Exception('Empty packet');
      }

      var offset = 0;

      // senderUserId
      final userIdLength = data[offset++];
      final senderUserId = utf8.decode(
        data.sublist(offset, offset + userIdLength),
      );
      offset += userIdLength;

      // messageId
      final messageIdLength = data[offset++];
      final messageId = utf8.decode(
        data.sublist(offset, offset + messageIdLength),
      );
      offset += messageIdLength;

      // replyToMessageId (optional)
      final replyLength = data[offset++];
      final replyToMessageId = replyLength == 0
          ? null
          : utf8.decode(data.sublist(offset, offset + replyLength));
      offset += replyLength;

      // message type
      final typeValue = data[offset++];

      // payload
      final payloadLength = ByteData.sublistView(
        data,
        offset,
        offset + _idLengthFieldBytes,
      ).getUint32(0);
      offset += _idLengthFieldBytes;

      final payload = data.sublist(offset, offset + payloadLength);

      return Packet(
        senderUserId: senderUserId,
        messageId: messageId,
        replyToMessageId: replyToMessageId,
        messageType: MessageType.fromValue(typeValue),
        payload: payload,
      );
    } catch (e) {
      Logger.log(error: e);
      rethrow;
    }
  }
}
