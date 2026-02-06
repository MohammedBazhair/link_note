import 'package:flutter/material.dart';
import '../../domain/entities/message.dart';
import '../widgets/chat/message_list.dart';

final mockMessages = [
  Message(
    id: '1',
    senderUserId: 'user_1',
    type: MessageType.text,
    text: 'مرحبا!',
    chatId: 'chat_123',
    time: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  Message(
    id: '2',
    senderUserId: 'user_2',
    type: MessageType.text,
    text: 'أهلاً كيف حالك؟',
    chatId: 'chat_123',
    time: DateTime.now().subtract(const Duration(minutes: 4)),
    replyToMessageId: '1',
  ),
  Message(
    id: '3',
    senderUserId: 'user_1',
    type: MessageType.text,
    text: 'تمام والحمد لله',
    chatId: 'chat_123',
    time: DateTime.now().subtract(const Duration(minutes: 2)),
    replyToMessageId: '2',
  ),
];

class TestChatScreen extends StatelessWidget {
  const TestChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تجربة الدردشة')),
      body: const MessageList(chatId: ''),
    );
  }
}
