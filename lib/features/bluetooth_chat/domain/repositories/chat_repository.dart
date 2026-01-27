import 'dart:typed_data';

import '../entities/message.dart';

abstract class ChatRepository {
  Stream<Message> get messages;

  Future<void> sendText(String peerUserId, String text);
  Future<void> sendImage(String peerUserId, Uint8List bytes);

  void dispose();
}
