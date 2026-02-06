import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../user/presentation/controllers/user_providers.dart';
import '../../../domain/entities/message.dart';
import '../../controllers/chat_providers.dart';
import '../../screens/test_chat_screen.dart';
import 'message_content.dart';

class MessageList extends ConsumerStatefulWidget {
  const MessageList({super.key, required this.chatId});
  final String chatId;

  @override
  ConsumerState<MessageList> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessageList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ref.listenManual(getChatMessagesProvider(widget.chatId), (
      oldMessages,
      newMessages,
    ) {
      if (oldMessages == null || oldMessages.length != newMessages.length) {
        return;
      }
      if (!_scrollController.hasClients) return;

      FocusScope.of(context).unfocus();

      final offset = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      _scrollController.jumpTo(offset);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final chatMessages = ref.watch(getChatMessagesProvider(widget.chatId));
    final chatMessages = mockMessages;

    if (chatMessages.isEmpty) {
      return const Center(child: Text('لا توجد رسائل بعد'));
    }

    final myId = ref.read(getUserIdProvider);

    return _ChatMessages(
      scrollController: _scrollController,
      myId: myId,
      chatMessages: chatMessages,
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
  final List<Message> chatMessages;
  final String? myId;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      itemCount: chatMessages.length,
      separatorBuilder: (context, index) {
        final currentMessage = chatMessages[index];
        final nextMessage = chatMessages[index + 1];
        final isSameSender =
            currentMessage.senderUserId == nextMessage.senderUserId;

        return isSameSender
            ? const SizedBox(height: 4)
            : const SizedBox(height: 20);
      },
      itemBuilder: (context, index) {
        final msg = chatMessages[index];
        final isMe = msg.senderUserId == myId;
        final hasTail =
            index == 0 ||
            chatMessages[index - 1].senderUserId != msg.senderUserId;

        return MessageWidget(isMe: isMe, message: msg, hasTail: hasTail);
      },
    );
  }
}
