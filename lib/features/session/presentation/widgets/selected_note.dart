import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/colors/colors.dart';
import '../../../../core/presentation/widgets/conditional_builder.dart';
import '../../../note/domain/entities/note.dart';
import '../../../note/presentation/controllers/note_providers.dart';
import '../../../note/presentation/widgets/note_tile.dart';

class SelectedNote extends ConsumerWidget {
  const SelectedNote({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final noteId = ref.watch(selectableNoteProvider).noteId;
    const fallbackChild = Center(child: Text('لم يتم اختيار ملاحظة بعد'));
    if (noteId == null) return fallbackChild;

    final asyncNote = ref.watch(getNoteByIdProvider(noteId));

    return asyncNote.when(
      data: (note) {
        return ConditionalBuilder(
          condition: note != null,
          fallback: (_) => fallbackChild,
          builder: (_) => SelectedNoteCard(note!),
        );
      },
      loading: () {
        return Skeletonizer(child: NoteTile(Note.fake()));
      },
      error: (_, __) {
        return fallbackChild;
      },
    );
  }
}

class SelectedNoteCard extends StatelessWidget {
  const SelectedNoteCard(this.note, {super.key});
  final Note note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2230),
        border: Border.all(color: DarkColors.primary.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
