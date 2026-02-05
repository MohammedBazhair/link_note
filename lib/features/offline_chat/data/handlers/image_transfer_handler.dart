import 'dart:io';

import 'package:uuid/uuid.dart';

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
  }) {
    final path = _completedPaths[payloadId];
    final senderId = _pendingSenders[payloadId];

    if (path == null || senderId == null) return null;

    final finalPath = '$path.png';
    final file = File(path);

    if (!file.existsSync()) return null;
    file.renameSync(finalPath);

    _pendingSenders.remove(payloadId);
    _completedPaths.remove(payloadId);

    return Message(
      id: const Uuid().v4(),
      senderUserId: senderId,
      type: MessageType.image,
      imagePath: finalPath,
      time: DateTime.now().toUtc(),
      chatId: Message.buildChatId(myUserId, senderId),
    );
  }

  void markFileCompleted(int payloadId, String filePath) {
    _completedPaths[payloadId] = filePath;
  }
}
