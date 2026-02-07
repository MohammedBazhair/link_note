import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../image/presentation/controllers/image_providers.dart';
import '../../controllers/chat_providers.dart';
import 'reply_message_widget.dart';

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

  void record() {}

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
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: Row(
        spacing: 7,
        crossAxisAlignment: CrossAxisAlignment.end,
        textDirection: TextDirection.rtl,
        children: [
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, child) {
              final isWriting = value.text.trim().isNotEmpty;

              return ChatInputButton(
                isWriting: isWriting,
                send: send,
                record: record,
              );
            },
          ),

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: const BoxDecoration(
                color: Color(0xFF343147),
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final repliedMessage = ref.watch(replyToMessageProvider);
                      return ReplyMessageWidget(
                        repliedMessage: repliedMessage,
                        hasCloseIcon: true,
                      );
                    },
                  ),

                  Row(
                    spacing: 4,
                    children: [
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
                          icon: const Icon(
                            Icons.image_outlined,
                            color: Colors.white,
                          ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatInputButton extends StatelessWidget {
  const ChatInputButton({
    super.key,
    required this.isWriting,
    required this.send,
    required this.record,
  });

  final bool isWriting;
  final VoidCallback send;
  final VoidCallback record;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isWriting ? send : record,
      customBorder: const CircleBorder(),

      child: CircleAvatar(
        backgroundColor: const Color(0xFF1976D2),
        radius: 26,

        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          reverseDuration: const Duration(milliseconds: 150),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: isWriting
              ? const Icon(key: ValueKey('send'), Icons.send)
              : const Icon(key: ValueKey('mic'), Icons.mic),
        ),
      ),
    );
  }
}
