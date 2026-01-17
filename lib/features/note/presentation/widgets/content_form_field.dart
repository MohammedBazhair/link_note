import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/note_providers.dart';
import 'ai_action_button.dart';

class ContentFormField extends StatelessWidget {
  const ContentFormField({
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
          decoration: const InputDecoration(
            hintText: 'اكتب ما تريد...',
            contentPadding: EdgeInsetsDirectional.only(
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
                final aiController = ref.read(noteAiProvider.notifier);
                final isProcessing = ref.watch(
                  noteAiProvider.select((s) => s.isContentProcessing),
                );

                return AiActionButton(
                  isProcessing: isProcessing,
                  onPressed: () async {
                    final content = await aiController.improveContent(
                      controller.text,
                    );
                    controller.text = content;
                    onChanged?.call(content);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
