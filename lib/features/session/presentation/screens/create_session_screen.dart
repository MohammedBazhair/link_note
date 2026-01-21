import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/providers/core_providers.dart';
import '../../../../core/presentation/widgets/loading_button.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart';
import '../../../note/domain/entities/selectable_note.dart';
import '../../../note/presentation/controllers/note_providers.dart';
import '../../../note/presentation/screens/notes_list_screen.dart';
import '../../domain/entities/session.dart';
import '../../handle_session_states.dart';
import '../../injection.dart';
import '../widgets/selected_note_preview.dart';
import 'active_session_screen.dart';

class CreateSessionScreen extends ConsumerStatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  ConsumerState<CreateSessionScreen> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends ConsumerState<CreateSessionScreen> {
  Future<void> _createSession() async {
    final selectableState = ref.read(selectableNoteProvider);
    final noteId = selectableState.noteId;
    if (!selectableState.hasNoteId) {
      return context.showSnakbar('يجب اختيار ملاحظة أولاً');
    }

    final hostId = ref.read(userControllerProvider.notifier).currentUser?.id;

    if (hostId == null) {
      await context.pushTo(const SignInScreen());
      return;
    }
    final session = Session(hostId: hostId, noteId: noteId);

    await ref.read(sessionControllerProvider.notifier).createSession(session);

    await context.pushTo(const ActiveSessionScreen());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionControllerProvider, (previous, current) async {
      await handleSessionStates(context, current: current, previous: previous);
    });

    return PopScope(
      onPopInvokedWithResult: (didPop, result) => ref
          .read(selectableNoteProvider.notifier)
          .update((_) => SelectableNote()),
      child: Scaffold(
        appBar: AppBar(title: const Text('إنشاء جلسة')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 30,
            children: [
              ElevatedButton(
                onPressed: () async {
                  ref
                      .read(selectableNoteProvider.notifier)
                      .update((s) => s.copyWith(isSelectable: true));
                  await context.pushTo(const NotesListScreen());
                },
                child: const Text('اختر ملاحظة'),
              ),

              const SelectedNotePreview(),
              MainButton(onPressed: _createSession, text: 'إنشاء جلسة'),
            ],
          ),
        ),
      ),
    );
  }
}
