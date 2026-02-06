import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio/presentation/controller/audio_provider.dart';
import '../../domain/entities/message.dart';
import 'chat_providers.dart';

/// Presentation-layer controller that exposes a flat list of all messages
/// across active chat sessions. UI widgets are responsible for filtering
/// by `chatId` where needed.
class ChatController extends Notifier<List<Message>> {
  @override
  List<Message> build() {
    final repo = ref.watch(chatRepository);
    Timer? timer;
    // Initial history
    final history = repo.messageHistory;
    final seenIds = <String>{for (final m in history) m.id};

    final sub = repo.messages.listen((msg) async {
      if (seenIds.contains(msg.id)) return;
      seenIds.add(msg.id);
      state = [...state, msg];
      if (timer?.isActive ?? false) return;

      timer = Timer(const Duration(seconds: 3), () {});
      await ref.read(audioControllerProvider.notifier).playBell();
    });

    ref.onDispose(() async {
      await sub.cancel();
      timer?.cancel();
    });

    return history;
  }

  void sendText({required String peerId, required String text,
     String? replyToMessageId,
  }) {
    ref.read(chatRepository).sendText(peerUserId: peerId, text: text);
  }

  void sendImage({required String peerId, required String filePath}) {
    ref.read(chatRepository).sendImage(peerUserId: peerId, filePath: filePath);
  }
}
