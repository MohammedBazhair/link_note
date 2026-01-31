import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/constants/internal_constants/log.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/presentation/widgets/conditional_builder.dart';
import '../../../domain/entities/message.dart';
import 'tail_message_paint.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({super.key, required this.isMe, required this.message});

  final bool isMe;
  final Message message;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isMe
        ? const Color(0xFF1976D2)
        : const Color(0xFF343147);
    return Align(
      alignment: isMe
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd,
      child: CustomPaint(
        painter: TailMessagePaint(isMe: isMe, color: backgroundColor),

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadiusDirectional.only(
              topStart: const Radius.circular(10),
              topEnd: const Radius.circular(10),
              bottomStart: isMe ? Radius.zero : const Radius.circular(10),
              bottomEnd: !isMe ? Radius.zero : const Radius.circular(10),
            ),
          ),
          child: MessageContnetWidget(message: message, isMe: isMe),
        ),
      ),
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
        return MessageText(text: '👋', time: message.time, isMe: isMe);

      case MessageType.text:
        return MessageText(
          text: message.text ?? '🙂',
          time: message.time,
          isMe: isMe,
        );
      case MessageType.image:
        return MessageImage(message: message);
    }
  }
}

class MessageImage extends StatelessWidget {
  const MessageImage({super.key, required this.message});
  final Message message;
  @override
  Widget build(BuildContext context) {
    Logger.log(message: message.toString());
    return ConditionalBuilder(
      condition: message.imagePath != null,
      builder: (_) =>
          Image.file(File(message.imagePath!), width: 250),
      fallback: (_) => const Text('صورة'),
    );
  }
}

class MessageText extends StatelessWidget {
  const MessageText({
    super.key,
    required this.text,
    required this.time,
    required this.isMe,
  });
  final String text;
  final DateTime time;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.end,
      children: [
        Text(
          text,
          style: TextStyle(
            color: isMe ? const Color(0xFFFFFFFF) : const Color(0xFFF1F0F4),
          ),
        ),
        Text(
          time.formatedChatTime,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade100.withOpacity(0.75),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
