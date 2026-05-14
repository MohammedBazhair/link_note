import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../audio/presentation/controller/audio_provider.dart';
import '../../../../audio/presentation/widgets/recording_waveform.dart';
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
  final textController = TextEditingController();
  final recorderController = RecorderController();

  void send() {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    final repliedMessage = ref.read(replyToMessageProvider);

    ref
        .read(chatControllerProvider.notifier)
        .sendText(
          peerId: widget.peerId,
          text: text,
          replyToMessageId: repliedMessage?.id,
        );

    ref.read(replyToMessageProvider.notifier).state = null;
    textController.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> recordOrStop() async {
    final controller = ref.read(voiceRecordControllerProvider.notifier);

    if (!recorderController.isRecording) {
      final hasPermission = await controller.startRecording();

      if (!hasPermission) {
        return context.showSnakbar('لا يمكن التسجيل بدون أذونات');
      }
      await recorderController.record();
      return;
    }

    await controller.stopRecording();
    await recorderController.stop();

    final filePath = ref.read(
      voiceRecordControllerProvider.select((s) => s.path),
    );

    if (filePath == null) {
      return context.showSnakbar('لم يتم الحصول على ملف التسجيل بنجاح');
    }

    final repliedMessage = ref.read(replyToMessageProvider);

    ref
        .read(chatControllerProvider.notifier)
        .sendVoiceRecord(
          peerId: widget.peerId,
          filePath: filePath,
          replyToMessageId: repliedMessage?.id,
        );

    ref.read(replyToMessageProvider.notifier).state = null;
  }

  Future<void> pickImage() async {
    final imagePath = await ref
        .read(imagePickerControllerProvider.notifier)
        .pickImage();
    if (imagePath == null) return;
    final repliedMessage = ref.read(replyToMessageProvider);
    ref
        .read(chatControllerProvider.notifier)
        .sendImage(
          peerId: widget.peerId,
          filePath: imagePath,
          replyToMessageId: repliedMessage?.id,
        );

    ref.read(replyToMessageProvider.notifier).state = null;
  }

  @override
  void dispose() {
    textController.dispose();
    recorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRecordingVoice = ref.watch(
      voiceRecordControllerProvider.select((s) => s.isRecording),
    );
    final repliedMessage = ref.watch(replyToMessageProvider);
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: Row(
        spacing: 7,
        crossAxisAlignment: CrossAxisAlignment.end,
        textDirection: TextDirection.rtl,
        children: [
          ValueListenableBuilder(
            valueListenable: textController,
            builder: (context, value, child) {
              final isWriting = value.text.trim().isNotEmpty;

              return ChatInputButton(
                isWriting: isWriting,
                isRecordingVoice: isRecordingVoice,
                send: send,
                record: recordOrStop,
              );
            },
          ),

          Expanded(
            child: Container(
              padding: repliedMessage != null
                  ? const EdgeInsets.all(7)
                  : const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF343147),
                borderRadius: BorderRadius.circular(
                  repliedMessage != null ? 15 : 30,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (repliedMessage != null)
                    ReplyMessageWidget(repliedMessage: repliedMessage),

                  if (isRecordingVoice)
                    RecordingWaveform(recorderController: recorderController),

                  if (!isRecordingVoice)
                    Row(
                      spacing: 4,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: textController,
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
                            controller: textController,
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
    required this.isRecordingVoice,
  });

  final bool isWriting;
  final bool isRecordingVoice;
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
              : isRecordingVoice
              ? const Icon(key: ValueKey('stop'), Icons.stop)
              : const Icon(key: ValueKey('mic'), Icons.mic),
        ),
      ),
    );
  }
}
