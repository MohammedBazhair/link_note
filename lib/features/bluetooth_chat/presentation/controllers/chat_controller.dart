
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/message.dart';
import 'chat_providers.dart';

/// Presentation-layer controller that exposes a flat list of all messages
/// across active chat sessions. UI widgets are responsible for filtering
/// by `chatId` where needed.
class ChatController extends Notifier<List<Message>> {
  @override
  List<Message> build() {
    final repo = ref.watch(chatRepository);

    // Initial history
    final history = repo.messageHistory;
    final seenIds = <String>{for (final m in history) m.id};

    final sub = repo.messages.listen((msg) {
      if (!seenIds.contains(msg.id)) {
        seenIds.add(msg.id);
        // We use state = ... to trigger UI rebuild
        state = [...state, msg];
      }
    });

    ref.onDispose(sub.cancel);

    return history;
  }

  void sendText({required String peerId, required String text}) {
    ref.read(chatRepository).sendText(peerUserId:  peerId,text: text);
  }

  void sendImage({required String peerId, required String filePath}) {
    ref.read(chatRepository).sendImage(peerUserId: peerId,filePath: filePath);
  }
}
