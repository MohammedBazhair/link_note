import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../user/presentation/controllers/user_providers.dart';
import '../../../domain/entities/message.dart';
import 'message_content.dart';

class MessageList extends ConsumerStatefulWidget {
  const MessageList({super.key, required this.messages, required this.chatId});

  final List<Message> messages;
  final String chatId;

  @override
  ConsumerState<MessageList> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessageList> {
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(MessageList oldWidget) {
    if (widget.messages.length == oldWidget.messages.length) return;
    if (!_scrollController.hasClients) return;

    FocusScope.of(context).unfocus();

    final offset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
    _scrollController.jumpTo(offset);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatMessages = widget.messages
        .where((m) => m.chatId == widget.chatId)
        .toList();

    if (chatMessages.isEmpty) {
      return const Center(child: Text('لا توجد رسائل بعد'));
    }

    final myId = ref.read(getUserIdProvider)!;
    return ListView.separated(
      controller: _scrollController,
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
