import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/message.dart';
import '../controllers/chat_providers.dart';
import '../controllers/nearby_providers.dart';
import '../widgets/chat/chat_appbar.dart';
import '../widgets/chat/chat_input.dart';
import '../widgets/chat/message_list.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key, required this.peerId, required this.myId});

  final String peerId;

  final String myId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatControllerProvider);
    final manager = ref.watch(nearbyConnectionManagerProvider);

    final chatAppbarParams = ChatParams(
      identity: manager.getIdentityByUserId(peerId)!,
      isConnected: manager.isConnected(peerId),
    );
    return Scaffold(
      body: Column(
        children: [
          SafeArea(child: ChatAppbar(chatAppbarParams)),
          Expanded(
            child: MessageList(
              messages: messages,
              chatId: Message.buildChatId(myId, peerId),
            ),
          ),
          ChatInput(peerId: peerId),
        ],
      ),
    );
  }
}
