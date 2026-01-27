import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../data/bluetooth/packet.dart';

enum MessageType {
  text(1),
  image(2);

  const MessageType(this.typeCode);

  final int typeCode;
}

class Message {
  Message({
    required this.id,
    required this.senderUserId,
    required this.type,
    this.text,
    this.imagePath,
    required this.time,
    required this.chatId,
  });

  factory Message.fromPacket({
    required Packet packet,
    required String senderId,
    required String myId,
  }) {
    final messageId = const Uuid().v4();
    final chatId = buildChatId(myId, senderId);
    final timeNow = DateTime.now().toUtc();
    return switch (packet.messageType) {
      MessageType.text => Message(
        id: messageId,
        chatId: chatId,
        senderUserId: senderId,
        type: packet.messageType,
        text: utf8.decode(packet.payload),
        time: timeNow,
      ),
      MessageType.image => Message(
        id: messageId,
        chatId: chatId,
        senderUserId: senderId,
        type: packet.messageType,
        imagePath:
            'received_image_${DateTime.now().millisecondsSinceEpoch}.png',
        time: DateTime.now().toUtc(),
      ),
    };
  }

  static String buildChatId(String a, String b) {
    final ids = [a, b]..sort();
    return ids.join('_');
  }

  final String id;
  final String chatId;
  final String senderUserId;
  final MessageType type;
  final String? text;
  final String? imagePath;
  final DateTime time;
}
