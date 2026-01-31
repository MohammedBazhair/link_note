import 'package:flutter/material.dart';

import '../../../domain/entities/message.dart';
import 'message_content.dart';

class MessageList extends StatelessWidget {
  const MessageList({
    super.key,
    required this.messages,
    required this.myId,
    required this.peerId,
  });

  final List<Message> messages;
  final String myId;
  final String peerId;

  String get chatId => Message.buildChatId(myId, peerId);

  @override
  Widget build(BuildContext context) {
    final chatMessages = messages.where((m) => m.chatId == chatId).toList();

    if (chatMessages.isEmpty) {
      return const Center(child: Text('لا توجد رسائل بعد'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: chatMessages.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final msg = chatMessages[index];
        final isMe = msg.senderUserId == myId;

        return MessageWidget(isMe: isMe, message: msg);
      },
    );
  }
}
