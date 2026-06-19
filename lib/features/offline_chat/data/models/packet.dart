import 'dart:typed_data';
import 'package:link_note/features/offline_chat/domain/entities/message_type.dart';

class Packet {
  Packet({
    required this.messageType,
    required this.payload,
    required this.senderUserId,
    required this.messageId,
     this.replyToMessageId,
  });

  final String messageId;
  final MessageType messageType;
  final Uint8List payload;
  final String senderUserId;
  final String? replyToMessageId;
  
}
