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
    final isConnected = ref.watch(isPeerConnectedProvider(peerId));
    final identity = ref.read(getIdentityByUserIdProvider(peerId));

    final chatAppbarParams = ChatParams(
      identity: identity,
      isConnected: isConnected,
    );
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(child: ChatAppbar(chatAppbarParams)),
          Expanded(
            child: MessageList(
              chatId: Message.buildChatId(myId, peerId),
              myId: myId,
            ),
          ),
          ChatInput(peerId: peerId),
        ],
      ),
    );
  }
}
