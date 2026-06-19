import 'package:link_note/features/offline_chat/domain/entities/reaction_emoji.dart';
import 'message_type.dart';

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

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      replyToMessageId: map['reply_To_Message_Id'] as String?,
      chatId: map['chat_id'] as String,
      senderUserId: map['sender_user_id'] as String,
      type: MessageType.fromValue(map['message_type'] as int),
      text: map['text'] as String?,
      reactionEmoji: ReactionEmoji.fromCode(map['reaction_emoji'] as int?),
      filePath: map['file_path'] as String?,
      time: DateTime.parse(map['time'] as String),
    );
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reply_To_Message_Id': replyToMessageId,
      'chat_id': chatId,
      'sender_user_id': senderUserId,
      'message_type': type.typeCode,
      'text': text,
      'reaction_emoji': reactionEmoji?.name,
      'file_path': filePath,
      'time': time.toIso8601String(),
    };
  }
}
