import 'dart:convert';
import 'package:flutter/foundation.dart';

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
    final writer = WriteBuffer();
    // Encode variable-length string fields as UTF-8
    final userIdBytes = utf8.encode(senderUserId);
    final messageIdBytes = utf8.encode(messageId);
    final replyBytes = utf8.encode(replyToMessageId ?? '');

    if (userIdBytes.length > 255) {
      throw Exception('UserId too long');
    }

    // senderUserId

    writer.putUint8(userIdBytes.length);
    writer.putUint8List(userIdBytes);

    // messageId
    writer.putUint8(messageIdBytes.length);
    writer.putUint8List(messageIdBytes);

    // replyToMessageId (optional)
    writer.putUint8(replyBytes.length);
    writer.putUint8List(replyBytes);

    // message metadata
    writer.putUint8(type.typeCode);
    writer.putUint32(payload.length);

    // payload
    writer.putUint8List(payload);

    return writer.done().buffer.asUint8List();
  }

  /// Deserializes a binary packet into a [Packet] object.
  ///
  /// Throws if the packet is malformed or incomplete.
  static Packet parsePacket(Uint8List data) {
    try {
      if (data.isEmpty) {
        throw Exception('Empty packet');
      }
      final reader = ReadBuffer(ByteData.sublistView(data));

      // senderUserId

      final userIdLength = reader.getUint8();
      final senderUserId = utf8.decode(reader.getUint8List(userIdLength));

      // messageId
      final messageIdLength = reader.getUint8();
      final messageId = utf8.decode(reader.getUint8List(messageIdLength));

      // replyToMessageId (optional)
      final replyLength = reader.getUint8();
      final replyToMessageId = replyLength == 0
          ? null
          : utf8.decode(reader.getUint8List(replyLength));

      // message type
      final typeValue = reader.getUint8();

      // payload
      final payloadLength = reader.getUint32();

      final payload = reader.getUint8List(payloadLength);

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
