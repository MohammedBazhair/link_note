import 'package:flutter/material.dart';

import '../../domain/entities/message.dart';

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

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: chatMessages.length,
      itemBuilder: (context, index) {
        final msg = chatMessages[index];
        final isMe = msg.senderUserId == myId;

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: MessageContnetWidget(message: msg, isMe: isMe),
          ),
        );
      },
    );
  }
}

class MessageContnetWidget extends StatelessWidget {
  const MessageContnetWidget({
    super.key,
    required this.message,
    required this.isMe,
  });
  final Message message;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case MessageType.handshake:
        return MessageText(text: '👋', isMe: isMe);
      case MessageType.text:
        return MessageText(text: message.text ?? '🙂', isMe: isMe);
      case MessageType.image:
        return MessageText(text: message.text ?? '📷 صورة', isMe: isMe);
    }
  }
}

class MessageText extends StatelessWidget {
  const MessageText({super.key, required this.text, required this.isMe});
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: isMe ? Colors.white : Colors.black),
    );
  }
}
