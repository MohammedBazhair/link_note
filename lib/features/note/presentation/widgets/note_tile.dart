import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/constants/colors/colors.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/widgets/tile_wrapper.dart';
import '../../domain/entities/note.dart';
import '../controllers/note_providers.dart';
import '../screens/note_editor_screen.dart';

class NoteTile extends ConsumerWidget {
  const NoteTile(this.note, {super.key});

  final Note note;

  @override
  Widget build(BuildContext context, ref) {
    final isSelected =
        ref.watch(selectableNoteProvider.select((s) => s.noteId)) == note.id;

    return TileWrapper(
      child: ListTile(
        minTileHeight: 73,
        tileColor: isSelected ? DarkColors.primary : Colors.transparent,
        title: Text(
          note.title.isEmpty ? note.content : note.title,
          maxLines: 1,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        subtitle:note.title.isEmpty ? null: Text(note.content, maxLines: 1),
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
      ),
    );
  }
}
