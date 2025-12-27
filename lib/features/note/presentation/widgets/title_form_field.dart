import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/note_ai_controller/note_ai_controller.dart';
import 'ai_action_button.dart';
import 'editor_form.dart';

class TitleFormField extends StatelessWidget {
  const TitleFormField({
    super.key,
    required this.controller,
    this.onChanged,
    this.readOnly = false,
  });
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: 2,
      minLines: 1,
      style: TextStyle(color: Colors.white.withAlpha(200)),
      cursorColor: const Color(0x809CDEBC),
      decoration: InputDecoration(
        hintText: 'Title...',
        suffixIcon: Consumer(
          builder: (_, ref, __) {
            final aiController = ref.read(noteAiProvider.notifier);
            final note = ref.read(editorFormProvider).note;

            final isProcessing = ref.watch(
              noteAiProvider.select((s) => s.isTitleProcessing),
            );

            return AiActionButton(
              isProcessing: isProcessing,
              onPressed: () async {
                if (note == null) return;
                await aiController.improveTitle(note);
              },
            );
          },
        ),
      ),
      onChanged: onChanged,
    );
  }
}
