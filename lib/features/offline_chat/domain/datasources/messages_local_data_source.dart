import 'package:link_note/features/offline_chat/domain/entities/message.dart';
import 'package:link_note/features/offline_chat/domain/entities/reaction_emoji.dart';

abstract class MessagesLocalDataSource {
  Future<void> saveMessage(Message message);

  Future<Message?> getMessageById(String messageId);

  Future<List<Message>> getChatMessages(String chatId);

  Future<void> deleteMessage(String messageId);

  Future<void> deleteChatMessages(String chatId);

  Future<void> updateReaction({
    required String messageId,
    required ReactionEmoji? reaction,
  });
}
