import 'package:link_note/features/offline_chat/domain/entities/reaction_emoji.dart';

import '../../presentation/controllers/chat_state.dart';
import '../entities/message.dart';

/// Business-level abstraction for chat operations.
///
/// This repository exposes a single stream of messages across all
/// active chats and user-centric send operations. It is intentionally
/// unaware of any Bluetooth or UI details.
abstract class ChatRepository {
  /// Stream of all incoming messages across all chat sessions.
  Stream<Message> get messages;

  /// Full history of messages in current session.
  Map<String, ChatRoom> get chatsHistory;

  Set<String> myChatFriendsIds(String myUserId);

  /// Sends a text message to the peer identified by their user id.
  void sendText({
    required String peerUserId,
    required String text,
    String? replyToMessageId,
  });

  /// Sends an image payload to the peer identified by their user id.
  void sendImage({
    required String peerUserId,
    required String filePath,
    String? replyToMessageId,
  });

  void sendVoiceRecord({
    required String peerUserId,
    required String filePath,
    String? replyToMessageId,
  });

  void sendEmoji({
    required String peerUserId,
    required ReactionEmoji reactionEmoji,
    required String messageId,
  });

  /// Disposes any resources held by the repository.
  void dispose();
}
