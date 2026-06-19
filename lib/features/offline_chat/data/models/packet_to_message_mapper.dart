import 'dart:convert';
import 'dart:typed_data';
import 'package:link_note/features/offline_chat/domain/entities/message.dart';
import 'package:link_note/features/offline_chat/domain/entities/message_type.dart';
import 'package:link_note/features/offline_chat/domain/entities/reaction_emoji.dart';
import 'packet.dart';

extension PacketToMessage on Packet {
  Message toMessage({required String myId}) {
    final messageId = this.messageId;
    final replyToMessageId = this.replyToMessageId;
    final chatId = Message.buildChatId(myId, senderUserId);
    final timeNow = DateTime.now().toUtc();
    return switch (messageType) {
      MessageType.text => Message(
        id: messageId,
        chatId: chatId,
        senderUserId: senderUserId,
        type: messageType,
        text: utf8.decode(payload),
        time: timeNow,
        replyToMessageId: replyToMessageId,
      ),
      MessageType.image => Message(
        id: messageId,
        chatId: chatId,
        senderUserId: senderUserId,
        type: messageType,
        filePath: 'received_image_${DateTime.now().millisecondsSinceEpoch}.png',
        time: timeNow,
        replyToMessageId: replyToMessageId,
      ),
      MessageType.handshake => Message(
        id: messageId,
        senderUserId: senderUserId,
        type: MessageType.handshake,
        time: timeNow,
        chatId: chatId,
      ),
      MessageType.voice => Message(
        id: messageId,
        chatId: chatId,
        senderUserId: senderUserId,
        type: messageType,
        filePath: 'received_voice_${DateTime.now().millisecondsSinceEpoch}.ogg',
        time: timeNow,
        replyToMessageId: replyToMessageId,
      ),
      MessageType.reactionEmoji => Message(
        id: messageId,
        senderUserId: senderUserId,
        type: messageType,
        time: timeNow,
        chatId: chatId,
        reactionEmoji: ReactionEmoji.fromCode(
          ByteData.sublistView(payload).getUint32(0),
        ),
      ),
    };
  }
}
