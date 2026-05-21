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
    return Column(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            maxLines: null,
            expands: true,
            readOnly: readOnly,
            textInputAction: TextInputAction.newline,

            keyboardType: TextInputType.multiline,

            textAlignVertical: TextAlignVertical.top,
            style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 15),
            cursorColor: const Color(0x809CDEBC),
            decoration: const InputDecoration(
              hintText: 'اكتب ما تريد...',
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: onChanged,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return "Field Can't be Empty";
              }
              return null;
            },
          ),
        ),
        _CounterWithAiAction(controller: controller, onChanged: onChanged),
      ],
    );
  }
}

class _CounterWithAiAction extends StatelessWidget {
  const _CounterWithAiAction({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

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
