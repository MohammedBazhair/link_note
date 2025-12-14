import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../note/domain/entities/note.dart';
import '../../../note/presentation/controllers/note_controller.dart';
import '../../../note/presentation/controllers/note_form_state.dart';
import '../../../note/presentation/widgets/content_form_field.dart';
import '../../../note/presentation/widgets/editor_form.dart';
import '../../../note/presentation/widgets/title_form_field.dart';
import '../controllers/session_controller.dart';
import '../widgets/session_code_card.dart';
import '../widgets/session_members_list.dart';
import '../widgets/session_popup_menu.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  StreamSubscription? _noteSubscription;

  @override
  void initState() {
    super.initState();
    final noteId = ref.read(sessionControllerProvider).session?.noteId ?? '';
    final note = ref.read(noteControllerProvider.notifier).getNoteById(noteId);
    ref.read(editorFormProvider).initForm(note);

    if (isHost) return;

    _noteSubscription = ref
        .read(noteControllerProvider.notifier)
        .fetchSingleNoteStream(noteId)
        .listen(ref.read(editorFormProvider).initForm);
  }

  @override
  void dispose() {
    _noteSubscription?.cancel();
    super.dispose();
  }

  Note? get currentNote => ref.read(editorFormProvider).note;

  NoteController get noteController =>
      ref.read(noteControllerProvider.notifier);

  EditorFormState get formState => ref.read(editorFormProvider);

  bool get isHost => ref.read(
    sessionControllerProvider.select((s) => s.currentMember?.isHost ?? false),
  );

  @override
  Widget build(BuildContext context) {
    final sessionCode = ref.read(
      sessionControllerProvider.select((s) => s.session?.sessionCode),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Title'),
        actions: const [SessionPopupMenu()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SessionCodeCard(sessionCode),

            const SizedBox(height: 30),

            const SessionMembersList(),

            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TitleFormField(
                      controller: formState.titleController,
                      readOnly: !isHost,
                      onChanged: (title) {
                        if (formState.note == null) return;
                        noteController.updateNote(formState.note!);
                        print(formState.note);
                      },
                    ),

                    const SizedBox(height: 24),

                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 200,
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: ContentFormField(
                        controller: formState.contentController,
                        readOnly: !isHost,
                        onChanged: (content) {
                          if (formState.note == null) return;

                          noteController.updateNote(formState.note!);
                          print(formState.note);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
