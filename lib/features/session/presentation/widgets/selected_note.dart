import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../note/presentation/controllers/note_controller.dart';
import '../../../note/presentation/widgets/note_tile.dart';

class SelectedNote extends StatelessWidget {
  const SelectedNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        final noteId = ref.watch(selectableNoteProvider).noteId;

        final note = ref
            .read(noteControllerProvider.notifier)
            .getNoteById(noteId);

        return (note != null) ? NoteTile(note) : const SizedBox.shrink();
      },
    );
  }
}
