import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/conditional_builder.dart';
import '../../../note/presentation/controllers/note_controller.dart';
import '../../../note/presentation/widgets/note_tile.dart';

class SelectedNote extends ConsumerWidget {
  const SelectedNote({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final noteId = ref.watch(selectableNoteProvider).noteId;
    const fallbackChild = Center(child: Text('لم يتم اختيار شيء'));
    if (noteId == null) return fallbackChild;

    final note = ref.read(noteControllerProvider.notifier).getNoteById(noteId);

    return ConditionalBuilder(
      condition: note != null,
      builder: (_) => NoteTile(note!),
      fallback: (_) => fallbackChild,
    );
  }
}
