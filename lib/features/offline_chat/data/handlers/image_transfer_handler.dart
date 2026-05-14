import 'dart:io';
import '../../domain/entities/message.dart';

class ImageTransferHandler {
  final Map<int, String> _pendingSenders = {};
  final Map<int, String> _pendingMessageIds = {};
  final Map<int, String> _pendingReplyIds = {};
  final Map<int, String> _completedPaths = {};

  Message? registerIncomingImage({
    required int payloadId,
    required String senderId,
    required String myUserId,
    required String messageId,
    String? replyToMessageId,
  }) {
    _pendingSenders[payloadId] = senderId;
    _pendingMessageIds[payloadId] = messageId;
    if (replyToMessageId != null) {
      _pendingReplyIds[payloadId] = replyToMessageId;
    }
    return tryBuildImageMessage(
      payloadId: payloadId,
      myUserId: myUserId,
    );
  }

  Message? tryBuildImageMessage({
    required int payloadId,
    required String myUserId,
  }) {
    final path = _completedPaths[payloadId];
    final senderId = _pendingSenders[payloadId];
    final messageId = _pendingMessageIds[payloadId];
    final replyToMessageId = _pendingReplyIds[payloadId];

    if (path == null || senderId == null || messageId == null) return null;

    final finalPath = '$path.png';
    final file = File(path);

    if (!file.existsSync()) return null;
    try {
      file.renameSync(finalPath);
    } catch (e) {
      return null;
    } finally {
      _pendingSenders.remove(payloadId);
      _pendingMessageIds.remove(payloadId);
      _pendingReplyIds.remove(payloadId);
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
