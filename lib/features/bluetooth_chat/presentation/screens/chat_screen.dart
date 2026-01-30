import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../image/presentation/controllers/image_providers.dart';
import '../controllers/chat_providers.dart';
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
    final manager = ref.watch(connectionManagerProvider);
    final displayName = manager.getDisplayNameByUuid(peerId);

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName == peerId ? 'دردشة' : displayName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Expanded(
              child: MessageList(
                messages: messages,
                myId: myId,
                peerId: peerId,
              ),
            ),
            ChatInput(
              onSend: (text) {
                ref
                    .read(chatControllerProvider.notifier)
                    .sendText(peerId: peerId, text: text);
              },
              onPickImage: () async {
                final imagePath = await ref
                    .read(imagePickerControllerProvider.notifier)
                    .pickImage();
                if (imagePath == null) return;
                ref
                    .read(chatControllerProvider.notifier)
                    .sendImage(peerId: peerId, filePath: imagePath);
              },
            ),
          ],
        ),
      ),
    );
  }
}
