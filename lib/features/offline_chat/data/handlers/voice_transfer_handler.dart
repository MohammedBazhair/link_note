import 'dart:io';
import '../../domain/entities/message.dart';

class VoiceTransferHandler {
  final Map<int, String> _pendingSenders = {};
  final Map<int, String> _completedPaths = {};

  Message? registerIncomingVoice({
    required int payloadId,
    required String senderId,
    required String myUserId,
    required String messageId,
    String? replyToMessageId,
  }) {
    _pendingSenders[payloadId] = senderId;
    return tryBuildVoiceMessage(
      payloadId: payloadId,
      myUserId: myUserId,
      messageId: messageId,
      replyToMessageId: replyToMessageId,
    );
  }

  Message? tryBuildVoiceMessage({
    required int payloadId,
    required String myUserId,
    required String messageId,
    String? replyToMessageId,
  }) {
    final path = _completedPaths[payloadId];
    final senderId = _pendingSenders[payloadId];

    if (path == null || senderId == null) return null;

    final finalPath = '$path.ogg';
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
      type: MessageType.voice,
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
