import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/constants/internal_constants/log.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/presentation/widgets/conditional_builder.dart';
import '../../../domain/entities/message.dart';
import 'message_text.dart';
import 'tail_message_paint.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.isMe,
    required this.message,
    required this.hasTail,
  });

  final bool isMe;
  final Message message;
  final bool hasTail;

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
        painter: hasTail
            ? TailMessagePaint(isMe: isMe, color: backgroundColor)
            : null,

        child: Dismissible(
          key: ValueKey(message.id),
          direction: DismissDirection.startToEnd,

          child: Container(
            padding: EdgeInsets.all(message.type == MessageType.image ? 3 : 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: !hasTail
                  ? BorderRadius.circular(13)
                  : BorderRadiusDirectional.only(
                      topStart: const Radius.circular(13),
                      topEnd: const Radius.circular(13),
                      bottomStart: isMe ? Radius.zero : const Radius.circular(13),
                      bottomEnd: !isMe ? Radius.zero : const Radius.circular(13),
                    ),
            ),
            child: MessageContnetWidget(message: message, isMe: isMe),
          ),
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
      condition: message.filePath != null,
      builder: (_) => Container(
        clipBehavior: Clip.antiAlias,
        width: 250,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(7.5)),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 4 / 5,
              child: Image.file(
                File(message.filePath!),
                width: 250,
                fit: BoxFit.cover,
              ),
            ),

            PositionedDirectional(
              bottom: 8,
              end: 9,
              child: Text(
                message.time.formattedChatTime,
                style: const TextStyle(
                  shadows: [
                    Shadow(blurRadius: 35, color: Color(0x993A3A3A)),
                    Shadow(blurRadius: 1, color: Color(0xAB000000)),
                  ],
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
      fallback: (_) => const Text('صورة'),
    );
  }
}
