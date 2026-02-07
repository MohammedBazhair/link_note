import 'dart:convert';

import '../../data/models/packet.dart';

enum MessageType {
  handshake(1),
  text(2),
  image(3),
  voice(4);

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
    this.replyToMessageId,
    this.text,
    this.filePath,
    required this.time,
    required this.chatId,
  });

  factory Message.fromPacket({
    required Packet packet,
    required String senderId,
    required String myId,
  }) {
    final messageId = packet.messageId;
    final replyToMessageId = packet.replyToMessageId;
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
        replyToMessageId: replyToMessageId
      ),
      MessageType.image => Message(
        id: messageId,
        chatId: chatId,
        senderUserId: senderId,
        type: packet.messageType,
        filePath: 'received_image_${DateTime.now().millisecondsSinceEpoch}.png',
        time: timeNow,
        replyToMessageId: replyToMessageId
      ),
      MessageType.handshake => Message(
        id: messageId,
        senderUserId: senderId,
        type: MessageType.handshake,
        time: timeNow,
        chatId: chatId,
      ),
      MessageType.voice => Message(
        id: messageId,
        chatId: chatId,
        senderUserId: senderId,
        type: packet.messageType,
        filePath: 'received_voice_${DateTime.now().millisecondsSinceEpoch}.ogg',
        time: timeNow,
        replyToMessageId: replyToMessageId,
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
  final String? replyToMessageId;
  final String chatId;
  final String senderUserId;
  final MessageType type;
  final String? text;
  final String? filePath;
  final DateTime time;

  @override
  String toString() {
    return 'Message(id: $id, chatId: $chatId, senderUserId: $senderUserId, type: $type, text: $text, imagePath: $filePath, time: $time)';
  }
}
