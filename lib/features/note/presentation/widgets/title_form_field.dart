import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/note_providers.dart';
import 'ai_action_button.dart';

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
      minLines: 1,
      style: TextStyle(color: Colors.white.withAlpha(200)),
      cursorColor: const Color(0x809CDEBC),
      decoration: InputDecoration(
        hintText: 'العنوان...',

        suffixIcon: readOnly
            ? null
            : Consumer(
                builder: (_, ref, __) {
                  final aiController = ref.read(noteAiProvider.notifier);
                  final note = ref.watch(editorFormProvider).note;

                  final isProcessing = ref.watch(
                    noteAiProvider.select((s) => s.isTitleProcessing),
                  );

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AiActionButton(
                      isProcessing: isProcessing,
                      onPressed: () async {
                        final title = await aiController.improveTitle(note);
                        controller.text = title;
                        onChanged?.call(title);
                      },
                    ),
                  );
                },
              ),
      ),
      onChanged: onChanged,
    );
  }
}
