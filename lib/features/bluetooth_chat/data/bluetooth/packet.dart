import 'dart:typed_data';

import '../../domain/entities/message.dart';

class Packet {
  Packet({
    required this.messageType,
    required this.payload,
    required this.senderUserId,
  });

  factory Packet.from({
    required int typeCode,
    required Uint8List payload,
    required String senderUserId,
  }) {
    final type = MessageType.values.firstWhere(
      (element) => element.typeCode == typeCode,
    );

    return Packet(
      messageType: type,
      payload: payload,
      senderUserId: senderUserId,
    );
  }

  final MessageType messageType;
  final Uint8List payload;
  final String senderUserId;
}
