import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/providers.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_list.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({
    super.key,
    required this.peerId,
    required this.myId,
    required this.peerUserId,
  });

  final String peerId;
  final String peerUserId;

  final String myId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Chat with $peerId')),
      body: Column(
        children: [
          Expanded(
            child: MessageList(messages: messages, myId: myId, peerId: peerId),
          ),
          ChatInput(
            onSend: (text) {
              ref
                  .read(chatControllerProvider.notifier)
                  .sendText(peerId: peerId, text: text);
            },
          ),
        ],
      ),
    );
  }
}
