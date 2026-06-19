import 'dart:io';
import 'package:link_note/features/offline_chat/domain/entities/message_type.dart';

import '../../domain/entities/message.dart';

class VoiceTransferHandler {
  final Map<int, String> _pendingSenders = {};
  final Map<int, String> _pendingMessageIds = {};
  final Map<int, String> _pendingReplyIds = {};
  final Map<int, String> _completedPaths = {};

  Message? registerIncomingVoice({
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
    return tryBuildVoiceMessage(
      payloadId: payloadId,
      myUserId: myUserId,
    );
  }

  Message? tryBuildVoiceMessage({
    required int payloadId,
    required String myUserId,
  }) {
    final path = _completedPaths[payloadId];
    final senderId = _pendingSenders[payloadId];
    final messageId = _pendingMessageIds[payloadId];
    final replyToMessageId = _pendingReplyIds[payloadId];

    if (path == null || senderId == null || messageId == null) return null;

    final finalPath = '$path.ogg';
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
