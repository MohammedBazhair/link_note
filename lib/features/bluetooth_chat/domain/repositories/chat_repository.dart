
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
  List<Message> get messageHistory;

  /// Sends a text message to the peer identified by their user id.
  void sendText({required String peerUserId, required String text});

  /// Sends an image payload to the peer identified by their user id.
  void sendImage({required String peerUserId, required String filePath});

  /// Disposes any resources held by the repository.
  void dispose();
}
