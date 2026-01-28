import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import 'providers.dart';

/// Presentation-layer controller that exposes a flat list of all messages
/// across active chat sessions. UI widgets are responsible for filtering
/// by `chatId` where needed.
class ChatController extends Notifier<List<Message>> {
  late final ChatRepository _repo;

  @override
  List<Message> build() {
    _repo = ref.read(chatRepository);
    _repo.messages.listen((msg) {
      state = [...state, msg];
    });
    return [];
  }

  void sendText({required String peerId, required String text}) {
    _repo.sendText(peerId, text);
  }

  void sendImage({required String peerId, required Uint8List bytes}) {
    _repo.sendImage(peerId, bytes);
  }
}
