import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../note/presentation/controllers/note_controller/note_controller.dart';
import '../../../note/presentation/controllers/note_controller/note_form_state.dart';
import '../../../note/presentation/widgets/content_form_field.dart';
import '../../../note/presentation/widgets/editor_form.dart';
import '../../../note/presentation/widgets/title_form_field.dart';
import '../controllers/session_controller.dart';
import 'session_code_card.dart';
import 'session_members_list.dart';

class SessionBody extends ConsumerStatefulWidget {
  const SessionBody({super.key});

  @override
  ConsumerState<SessionBody> createState() => _SessionBodyState();
}

class _SessionBodyState extends ConsumerState<SessionBody> {
  Timer? _debounce;


  void updateNoteDebounced() {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(seconds: 2),
      () =>
          ref.read(noteControllerProvider.notifier).updateNote(formState.note),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  EditorFormState get formState => ref.watch(editorFormProvider);

  @override
  Widget build(BuildContext context) {
    final isHost = ref.watch(
      sessionControllerProvider.select((s) => s.currentMember?.isHost ?? false),
    );
    final sessionCode = ref.watch(
      sessionControllerProvider.select((s) => s.session?.sessionCode),
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        spacing: 20,
        children: [
          SessionCodeCard(sessionCode),
          const SessionMembersList(),

          TitleFormField(
            controller: formState.titleController,
            readOnly: !isHost,
            onChanged: (_) => updateNoteDebounced(),
          ),

          Expanded(
            child: ContentFormField(
              controller: formState.contentController,
              readOnly: !isHost,
              onChanged: (_) => updateNoteDebounced(),
            ),
          ),
        ],
      ),
    );
  }
}
