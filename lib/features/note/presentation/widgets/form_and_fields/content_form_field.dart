import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/colors/colors.dart';
import '../../controllers/note_providers.dart';
import '../ai_action_button.dart';

class ContentFormField extends ConsumerWidget {
  const ContentFormField({super.key, this.readOnly = false, this.onChanged});
  final VoidCallback? onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context, ref) {
    final contentController = ref.watch(noteFormProvider).content;
    return Column(
      children: [
        Expanded(
          child: Consumer(
            builder: (_, ref, __) {
              final textDirection = ref.watch(
                editorControllerProvider.select((s) => s.contentDirection),
              );

              return TextFormField(
                controller: contentController,
                textDirection: textDirection,
                maxLines: null,
                expands: true,
                readOnly: readOnly,
                textInputAction: TextInputAction.newline,
                onChanged: (content) {
                  final historyController = ref.read(
                    editorControllerProvider.notifier,
                  );

                  historyController.updateEditorContent(content: content);
                },
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 15,
                ),
                cursorColor: const Color(0x809CDEBC),
                decoration: const InputDecoration(
                  hintText: 'اكتب ما تريد...',
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return "Field Can't be Empty";
                  }
                  return null;
                },
              );
            },
          ),
        ),
        _CounterWithAiAction(controller: contentController),
      ],
    );
  }
}

class _CounterWithAiAction extends StatelessWidget {
  const _CounterWithAiAction({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Consumer(
          builder: (_, ref, __) {
            final aiController = ref.read(noteAiNotiferProvider.notifier);
            final isProcessing = ref.watch(
              noteAiNotiferProvider.select((s) => s.isContentProcessing),
            );
            return AiActionButton(
              tooltip: 'تحسين المحتوى عبر AI',
              isProcessing: isProcessing,
              onPressed: () async {
                final note = ref.read(currentNoteControllerProvider).note;
                if (note == null) return;
                final content = await aiController.improveContent(note);
                controller.text = content;
              },
            );
          },
        ),

        ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, value, _) {
            return Text(
              '${controller.text.length}',
              style: const TextStyle(
                fontSize: 11,
                height: 2.5,
                color: DarkColors.secondFont,
              ),
            );
          },
        ),
      ],
    );
  }
}
