import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/features/offline_chat/domain/entities/message.dart';
import 'package:link_note/features/offline_chat/presentation/controllers/chat_providers.dart';
import 'package:link_note/features/offline_chat/presentation/widgets/chat/message_bubble.dart';
import 'package:link_note/features/offline_chat/presentation/widgets/chat/reaction_popup.dart';

class TestReactionPage extends ConsumerWidget {
  const TestReactionPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final portalController = ref.read(overlayPortalController);

    return Scaffold(
      appBar: AppBar(title: const Text('تجربة ايموجيات التفاعل')),
      body: OverlayPortal(
        controller: portalController,
        overlayChildBuilder: (context) {
          final link = ref.watch(currentLayerLinkProvider);

          if (link == null) return const SizedBox.shrink();

          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    ref.read(currentLayerLinkProvider.notifier).state = null;
                    portalController.hide();
                  },
                  child: const ColoredBox(color: Colors.transparent),
                ),
              ),
              CompositedTransformFollower(
                link: link,
                offset: const Offset(0, -60),
                child: const Material(
                  color: Colors.transparent,
                  child: ReactionPopup(onSelected: print),
                ),
              ),
            ],
          );
        },

        child: ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: 10,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final message = Message(
              id: '$index',
              senderUserId: 'senderUserId',
              type: MessageType.text,
              time: DateTime.now(),
              chatId: 'chatId',
              text: 'Testing Message $index' * index * index,
            );
            return MessageBubble(isMe: false, message: message, hasTail: true);
          },
        ),
      ),
    );
  }
}
