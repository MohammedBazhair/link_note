import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/note_providers.dart';
import 'ai_action_button.dart';

class TitleFormField extends ConsumerWidget {
  const TitleFormField({super.key, this.readOnly = false});
  final bool readOnly;

  @override
  Widget build(BuildContext context, ref) {
    final titleController = ref.watch(noteFormProvider).title;
    return TextFormField(
      controller: titleController,
      readOnly: readOnly,
      textInputAction: TextInputAction.newline,
      minLines: 1,
      maxLines: 2,
      maxLength: 100,
      keyboardType: TextInputType.multiline,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: const Color(0x809CDEBC),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        hintText: 'العنوان...',
        filled: false,
        counterText: '',

        suffixIcon: readOnly
            ? null
            : Consumer(
                builder: (_, ref, __) {
                  final aiController = ref.read(noteAiNotiferProvider.notifier);

                  final isProcessing = ref.watch(
                    noteAiNotiferProvider.select((s) => s.isTitleProcessing),
                  );

                  return AiActionButton(
                    tooltip: 'تحسين العنوان عبر AI',
                    isProcessing: isProcessing,
                    onPressed: () async {
                      final note = ref.read(
                        editorFormControllerProvider.select((s) => s.note),
                      );
                      if (note == null) return;

                      final title = await aiController.improveTitle(note);

                      titleController.text = title;
                    },
                  );
                },
              ),
      ),
    );
  }
}
