import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../note/domain/entities/note.dart';
import '../../../note/presentation/controllers/note_controller/note_controller.dart';
import '../../../note/presentation/widgets/content_form_field.dart';
import '../../../note/presentation/widgets/editor_form.dart';
import '../../../note/presentation/widgets/title_form_field.dart';
import '../controllers/session_controller.dart';
import 'session_members_list.dart';

class SessionBody extends ConsumerWidget {
  const SessionBody({super.key, required this.note});
  final Note note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(editorFormProvider);
    final isHost = ref.watch(
      sessionControllerProvider.select((s) => s.currentMember?.isHost ?? false),
    );

    void updateNote() {
      ref.read(noteControllerProvider.notifier).updateNote(formState.note!);
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SessionMembersList(),
          const SizedBox(height: 24),

          TitleFormField(
            controller: formState.titleController,
            readOnly: !isHost,
            onChanged: (_) => updateNote(),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: ContentFormField(
              controller: formState.contentController,
              readOnly: !isHost,
              onChanged: (_) => updateNote(),
            ),
          ),
        ],
      ),
    );
  }
}
