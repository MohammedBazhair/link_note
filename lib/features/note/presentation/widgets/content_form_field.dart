import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors/colors.dart';
import '../controllers/note_providers.dart';
import 'ai_action_button.dart';

class ContentFormField extends StatelessWidget {
  const ContentFormField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.readOnly = false,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextFormField(
          controller: controller,
          maxLines: null,
          expands: true,
          readOnly: readOnly,

          textAlignVertical: TextAlignVertical.top,
          style: TextStyle(color: Colors.white.withAlpha(200)),
          cursorColor: const Color(0x809CDEBC),
          decoration: InputDecoration(
            hintText: 'اكتب ما تريد...',
            counter: ValueListenableBuilder(
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
            contentPadding: const EdgeInsetsDirectional.only(
              end: 40,
              start: 15,
              bottom: 15,
              top: 15,
            ),
          ),
          onChanged: onChanged,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return "Field Can't be Empty";
            }
            return null;
          },
        ),

        if (!readOnly)
          PositionedDirectional(
            end: 5,
            top: 5,
            child: Consumer(
              builder: (_, ref, __) {
                final aiController = ref.read(noteAiNotiferProvider.notifier);
                final isProcessing = ref.watch(
                  noteAiNotiferProvider.select((s) => s.isContentProcessing),
                );
                return AiActionButton(
                  isProcessing: isProcessing,
                  onPressed: () async {
                    final note = ref.watch(editorFormProvider).note;

                    final content = await aiController.improveContent(note);
                    controller.text = content;
                    onChanged(content);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
