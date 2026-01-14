import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/widgets/loading_button.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart';
import '../../../note/presentation/screens/notes_list_screen.dart';
import '../../../note/presentation/widgets/note_tile.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import '../../domain/entities/session.dart';
import '../controllers/session_controller.dart';
import '../screens/session_screen.dart';
import 'selected_note.dart';

class CreateSessionForm extends ConsumerWidget {
  const CreateSessionForm({super.key, });

  @override
  Widget build(BuildContext context, ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 15,
      children: [
        const Text('إنشاء جلسة تعاون لمشاركة وتحرير الملاحظات'),
        ElevatedButton(
          onPressed: () async {
            ref
                .read(selectableNoteProvider.notifier)
                .update((s) => s.copyWith(isSelectable: true));
            await context.pushTo(const NotesListScreen());
          },
          child: const Text('اختر ملاحظة'),
        ),
        const SizedBox(height: 16),
        const SelectedNote(),
        const SizedBox(height: 15),
        MainButton(
          text: 'إنشاء الجلسة',
          onPressed: () async {
            final selectable = ref.read(selectableNoteProvider);

            if (!selectable.hasNoteId) {
              context.showSnakbar('يجب اختيار ملاحظة أولاً');
              return;
            }

            final hostId = ref
                .read(userControllerProvider.notifier)
                .currentUser
                ?.id;

            if (hostId == null) {
              await context.pushTo(const SignInScreen());
              return;
            }

            final session = Session(hostId: hostId, noteId: selectable.noteId);

            await ref
                .read(sessionControllerProvider.notifier)
                .createSession(session);
      await context.pushTo(const SessionScreen());

          },
        ),
      ],
    );
  }
}
