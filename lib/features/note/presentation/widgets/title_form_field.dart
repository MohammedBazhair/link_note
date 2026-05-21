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
                  final note = ref.watch(editorFormProvider).note;

                  final isProcessing = ref.watch(
                    noteAiNotiferProvider.select((s) => s.isTitleProcessing),
                  );

                  return AiActionButton(
                    isProcessing: isProcessing,
                    onPressed: () async {
                      final title = await aiController.improveTitle(note);
                      controller.text = title;
                      onChanged?.call(title);
                    },
                  );
                },
              ),
      ),
      onChanged: onChanged,
    );
  }
}
