import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../image/presentation/controllers/image_providers.dart';
import '../../../../qr_code/presentation/widgets/filled_icon_button.dart';
import '../../controllers/chat_providers.dart';

class ChatInput extends ConsumerStatefulWidget {
  const ChatInput({super.key, required this.peerId});
  final String peerId;
  @override
  ConsumerState<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<ChatInput> {
  final controller = TextEditingController();

  void send() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    ref
        .read(chatControllerProvider.notifier)
        .sendText(peerId: widget.peerId, text: text);

    controller.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> pickImage() async {
    final imagePath = await ref
        .read(imagePickerControllerProvider.notifier)
        .pickImage();
    if (imagePath == null) return;
    ref
        .read(chatControllerProvider.notifier)
        .sendImage(peerId: widget.peerId, filePath: imagePath);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: BoxBorder.fromSTEB(
          top: const BorderSide(color: Color(0x6E083141), width: .8),
        ),
      ),
      child: Row(
        spacing: 4,
        children: [
          FilledIconButton(
            onPressed: send,
            iconData: Icons.send,
            backgroundColor: Colors.blue.shade800,
          ),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, pickerImageIcon) {
              final isWriting = value.text.trim().isNotEmpty;

              return AnimatedCrossFade(
                firstChild: pickerImageIcon!,
                secondChild: const SizedBox.shrink(),
                firstCurve: Curves.bounceOut,
                secondCurve: Curves.fastLinearToSlowEaseIn,
                crossFadeState: isWriting
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              );
            },
            child: IconButton(
              onPressed: pickImage,
              icon: const Icon(Icons.image_outlined, color: Colors.white),
              tooltip: 'إرسال صورة',
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 6,
              minLines: 1,

              decoration: const InputDecoration(
                hintText: 'اكتب رسالة...',
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 13.2,
                height: 1.6,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
