import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/features/note/presentation/controllers/note_providers.dart';
import 'package:link_note/features/note/presentation/widgets/notes_contextual_action_bar/selected_notes_text.dart';

class NotesContextualActionBar extends ConsumerWidget {
  const NotesContextualActionBar({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Row(
      spacing: 10,
      children: [
        CloseButton(
          onPressed: () {
            ref
                .read(notesContextualActionBarController.notifier)
                .closeActionBar();
          },
        ),

        const SelectedNotesCounterText(),

        const Spacer(),

        IconButton(
          onPressed: ref
              .read(notesContextualActionBarController.notifier)
              .deleteSelectedNotes,
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }
}
