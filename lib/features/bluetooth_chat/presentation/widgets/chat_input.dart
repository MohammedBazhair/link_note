import 'package:flutter/material.dart';

import '../../../qr_code/presentation/widgets/filled_icon_button.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({super.key, required this.onSend, required this.onPickImage});

  final ValueChanged<String> onSend;
  final Future<void> Function() onPickImage;

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
    return Row(
      spacing: 8,
      children: [
        FilledIconButton(onPressed: send, iconData: Icons.send),
    
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'اكتب رسالة...'),
          ),
        ),
        IconButton(
          onPressed: () => widget.onPickImage.call(),
          icon: const Icon(Icons.image_outlined),
          tooltip: 'إرسال صورة',
        ),
      ],
    );
  }
}
