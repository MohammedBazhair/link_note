import 'package:flutter/material.dart';

import '../../domain/entities/message.dart';

class BuildMessageContent extends StatelessWidget {
  const BuildMessageContent({super.key, required this.message});
  final Message message;

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Text(message.text ?? '', style: const TextStyle(fontSize: 16));
      case MessageType.image:
        return const Text('📷 Image');
      case MessageType.handshake:
        return const Text('Handshake');
    }
  }
}
