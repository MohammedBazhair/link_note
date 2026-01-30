import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/internal_constants/log.dart';
import '../../../../core/presentation/widgets/conditional_builder.dart';
import '../../domain/entities/message.dart';

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
        return MessageText(text: '👋', isMe: isMe);
      case MessageType.text:
        return MessageText(text: message.text ?? '🙂', isMe: isMe);
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
          Image.file(File(message.imagePath!), width: 250, height: 250),
      fallback: (_) => const Text('صورة'),
    );
  }
}

class MessageText extends StatelessWidget {
  const MessageText({super.key, required this.text, required this.isMe});
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: isMe ? Colors.white : Colors.black),
    );
  }
}
