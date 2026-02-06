import 'dart:io';
import '../../domain/entities/message.dart';

class ImageTransferHandler {
  final Map<int, String> _pendingSenders = {};
  final Map<int, String> _completedPaths = {};

  void registerIncomingImage(int payloadId, String senderId) {
    _pendingSenders[payloadId] = senderId;
  }

  Message? tryBuildImageMessage({
    required int payloadId,
    required String myUserId,
    required String messageId,
    String? replyToMessageId,
  }) {
    final path = _completedPaths[payloadId];
    final senderId = _pendingSenders[payloadId];

    if (path == null || senderId == null) return null;

    final finalPath = '$path.png';
    final file = File(path);

    if (!file.existsSync()) return null;
    try {
      file.renameSync(finalPath);
    } catch (e) {
      return null;
    } finally {
      _pendingSenders.remove(payloadId);
      _completedPaths.remove(payloadId);
    }

    return Message(
      id: messageId,
      senderUserId: senderId,
      type: MessageType.image,
      filePath: finalPath,
      time: DateTime.now().toUtc(),
      chatId: Message.buildChatId(myUserId, senderId),
      replyToMessageId: replyToMessageId,
    );
  }

  void markFileCompleted(int payloadId, String filePath) {
    _completedPaths[payloadId] = filePath;
  }
}
