import 'package:flutter/material.dart';

import '../../../qr_code/presentation/widgets/filled_icon_button.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({super.key, required this.onSend});

  final ValueChanged<String> onSend;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final controller = TextEditingController();

  void send() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    widget.onSend(text);
    controller.clear();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'اكتب رسالة...'),
            ),
          ),
          const SizedBox(width: 8),
          FilledIconButton(onPressed: send, iconData: Icons.send),
        ],
      ),
    );
  }
}
