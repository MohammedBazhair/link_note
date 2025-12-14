import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/selectable_note.dart';
import '../screens/note_editor_screen.dart';

final selectableNoteProvider = StateProvider.autoDispose(
  (_) => SelectableNote(),
);

class NoteTile extends ConsumerWidget {
  const NoteTile(this.note, {super.key});

  final Note note;

  @override
  Widget build(BuildContext context, ref) {
    final isSelected =
        ref.watch(selectableNoteProvider.select((s) => s.noteId)) == note.id;

    return ListTile(
      title: Text(note.title.isEmpty ? 'No Title' : note.title, maxLines: 1),
      subtitle: Text(note.content, maxLines: 1),
      trailing: Skeleton.ignore(
        child: isSelected
            ? const Icon(Icons.check_circle_outline_rounded, size: 30)
            : const SizedBox.shrink(),
      ),
      selected: isSelected,
      onTap: () {
        if (ref.read(selectableNoteProvider).isSelectable) {
          ref
              .read(selectableNoteProvider.notifier)
              .update((s) => s.copyWith(noteId: note.id));
          return;
        }

        context.pushTo(NoteEditorScreen(note: note));
      },
    );
  }
}
