import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/core/extensions/extensions.dart';
import 'package:link_note/features/offline_chat/domain/entities/message.dart';
import '../../controllers/chat_providers.dart';
import 'message_bubble.dart';
import 'reaction_popup.dart';

class MessageList extends ConsumerStatefulWidget {
  const MessageList({super.key, required this.peerId, required this.myId});
  final String peerId;
  final String myId;

  @override
  ConsumerState<MessageList> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessageList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ref.listenManual(getChatMessagesProvider(chatId), (
      oldMessages,
      newMessages,
    ) {
      if (oldMessages != null && newMessages.length <= oldMessages.length) {
        return;
      }
      if (!_scrollController.hasClients) return;

      FocusScope.of(context).unfocus();

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!_scrollController.hasClients) return;
        final offset = _scrollController.position.maxScrollExtent;
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      });
    });

    ref.listenManual(chatContextualActionBarController, (_, state) {
      final errorMessage = state.errorMessage;
      final successMessage = state.successMessage;

      if (errorMessage != null) context.showSnakbar(errorMessage);
      if (successMessage != null) context.showSnakbar(successMessage);
    });

    Future.microtask(() {
      ref
          .read(reactionEmojiControllerProvider.notifier)
          .loadChatData(chatId: chatId, peerId: widget.peerId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String get chatId => Message.buildChatId(widget.myId, widget.peerId);

  @override
  Widget build(BuildContext context) {
    final chatMessages = ref.watch(getChatMessagesProvider(chatId));

    if (chatMessages.isEmpty) {
      return const Center(child: Text('لا توجد رسائل بعد'));
    }
    final reactionController = ref.read(
      reactionEmojiControllerProvider.notifier,
    );
    return OverlayPortal(
      controller: reactionController.portalController,
      overlayChildBuilder: (context) {
        final currentLink = ref.watch(
          reactionEmojiControllerProvider.select((s) => s.currentLayerLink),
        );

        if (currentLink == null) return const SizedBox.shrink();
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: reactionController.hideReactionPopup,
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            CompositedTransformFollower(
              link: currentLink,
              offset: const Offset(0, -60),
              child: Material(
                color: Colors.transparent,
                child: ReactionPopup(
                  onSelected: (reaction) =>
                      reactionController.onEmojiSelected(reaction: reaction),
                ),
              ),
            ),
          ],
        );
      },
      child: _ChatMessages(
        scrollController: _scrollController,
        myId: widget.myId,
        chatMessages: chatMessages,
      ),
    );
  }
}

class _ChatMessages extends StatelessWidget {
  const _ChatMessages({
    required ScrollController scrollController,
    required this.myId,
    required this.chatMessages,
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;
  final ChatMessagesMap chatMessages;
  final String? myId;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      itemCount: chatMessages.length,
      separatorBuilder: (context, index) {
        final currentMessage = chatMessages.values.elementAt(index);
        final nextMessage = chatMessages.values.elementAt(index + 1);
        final isSameSender =
            currentMessage.senderUserId == nextMessage.senderUserId;

        return isSameSender
            ? const SizedBox(height: 4)
            : const SizedBox(height: 20);
      },
      itemBuilder: (context, index) {
        final msg = chatMessages.values.elementAt(index);
        final isMe = msg.senderUserId == myId;
        final hasTail =
            index == 0 ||
            chatMessages.values.elementAt(index - 1).senderUserId !=
                msg.senderUserId;

        return MessageBubble(
          isMe: isMe,
          message: msg,
          hasTail: hasTail,
          repliedMessage: chatMessages[msg.replyToMessageId],
        );
      },
    );
  }
}
