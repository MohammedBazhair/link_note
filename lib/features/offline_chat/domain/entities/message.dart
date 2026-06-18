// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:link_note/features/offline_chat/domain/entities/reaction_emoji.dart';

import '../../data/models/packet.dart';

enum MessageType {
  handshake(1),
  text(2),
  image(3),
  voice(4),
  reactionEmoji(5);

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
    this.reactionEmoji,
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
        replyToMessageId: replyToMessageId,
      ),
      MessageType.image => Message(
        id: messageId,
        chatId: chatId,
        senderUserId: senderId,
        type: packet.messageType,
        filePath: 'received_image_${DateTime.now().millisecondsSinceEpoch}.png',
        time: timeNow,
        replyToMessageId: replyToMessageId,
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
      MessageType.reactionEmoji => Message(
        id: messageId,
        senderUserId: senderId,
        type: packet.messageType,
        time: timeNow,
        chatId: chatId,
        reactionEmoji: ReactionEmoji.fromString(utf8.decode(packet.payload)),
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
  final ReactionEmoji? reactionEmoji;
  final String? filePath;
  final DateTime time;

  @override
  String toString() {
    return 'Message(id: $id, chatId: $chatId, senderUserId: $senderUserId, type: $type, text: $text, imagePath: $filePath, time: $time)';
  }

  static const _sentinel = Object();

  Message copyWith({
    String? id,
    String? replyToMessageId,
    String? chatId,
    String? senderUserId,
    MessageType? type,
    String? text,
    Object? reactionEmoji = _sentinel,
    String? filePath,
    DateTime? time,
  }) {
    return Message(
      id: id ?? this.id,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      chatId: chatId ?? this.chatId,
      senderUserId: senderUserId ?? this.senderUserId,
      type: type ?? this.type,
      text: text ?? this.text,
      reactionEmoji: identical(reactionEmoji, _sentinel)
          ? this.reactionEmoji
          : reactionEmoji as ReactionEmoji?,
      filePath: filePath ?? this.filePath,
      time: time ?? this.time,
    );
  }
}
