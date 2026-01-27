import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import 'providers.dart';

class ChatController extends Notifier<List<Message>> {
  ChatController() {
    _repo.messages.listen((msg) {
      state = [...state, msg];
    });
  }
  late final ChatRepository _repo;

  @override
  List<Message> build() {
    _repo = ref.read(chatRepository);
    return [];
  }

  void sendText(String peerId, String text) {
    _repo.sendText(peerId, text);
  }

  void sendImage(String peerId, Uint8List bytes) {
    _repo.sendImage(peerId, bytes);
  }
}
