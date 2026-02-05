import 'dart:convert';

import '../../data/models/packet.dart';

enum MessageType {
  handshake(1),
  text(2),
  image(3);

  const MessageType(this.typeCode);
  static MessageType fromValue(int v) {
    return MessageType.values.firstWhere(
      (e) => e.typeCode == v,
      orElse: () => MessageType.text,
    );
  }

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
    final messageId = packet.messageId;
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
        time: timeNow,
      ),
      MessageType.handshake => Message(
        id: messageId,
        senderUserId: senderId,
        type: MessageType.handshake,
        time: timeNow,
        chatId: chatId,
      ),
    };
  }

  static String buildChatId(String a, String b) {
    final s1 = a.trim().toLowerCase();
    final s2 = b.trim().toLowerCase();
    final ids = [s1, s2]..sort();
    return ids.join('_');
  }

  final String id;
  final String chatId;
  final String senderUserId;
  final MessageType type;
  final String? text;
  final String? imagePath;
  final DateTime time;

  @override
  String toString() {
    return 'Message(id: $id, chatId: $chatId, senderUserId: $senderUserId, type: $type, text: $text, imagePath: $imagePath, time: $time)';
  }
}
