import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/constants/colors/colors.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/note.dart';
import '../controllers/current_note_controller/current_note_state.dart';
import '../controllers/note_providers.dart';
import '../screens/note_editor_screen.dart';

final _hoverNoteProvider = StateProvider.family.autoDispose((ref, id) => false);

class NoteTile extends ConsumerWidget {
  const NoteTile({super.key, required this.note});

  final Note note;

  @override
  Widget build(BuildContext context, ref) {
    final noteId = note.id;
    if (noteId == null) return const SizedBox.shrink();

    final isChecked = ref.watch(
      notesContextualActionBarController.select(
        (s) => s.selectedNotesIds.contains(noteId),
      ),
    );
    return InkWell(
      hoverColor: Colors.transparent,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      onTap: () {
        final controller = ref.read(
          notesContextualActionBarController.notifier,
        );
        final isContextualMode = ref
            .read(notesContextualActionBarController)
            .actionBarOpened;

        if (isContextualMode) {
          controller.toggleNote(noteId);
        } else {
          context.pushTo(
            NoteEditorScreen(
              functionality: CurrentNoteFunctionality.edit,
              note: note,
            ),
          );
        }
      },
      onLongPress: () {
        ref
            .read(notesContextualActionBarController.notifier)
            .toggleNote(noteId);
      },
      onHover: (value) =>
          ref.read(_hoverNoteProvider(noteId).notifier).state = value,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            color: isChecked
                ? const Color(0xDA252A3B)
                : const Color(0xAE1E2230),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                width: isChecked ? 1 : 0.3,
                color: isChecked
                    ? const Color(0x79021A31)
                    : const Color(0x7A222327),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 2,
                          fontWeight: FontWeight.w500,
                          color: Color(0xE0FFFFFF),
                        ),
                      ),
                      Text(
                        note.content,
                        maxLines: 3,

                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: DarkColors.secondFont,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Divider(
                        color: Color.fromARGB(88, 94, 94, 94),
                        thickness: 0.5,
                        height: 20,
                      ),
                      Text(
                        note.lastUpdateText,

                        style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(157, 1, 183, 193),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          PositionedDirectional(
            bottom: 0,
            end: 0,
            child: NoteCheckButton(noteId: noteId),
          ),
        ],
      ),
    );
  }
}

class NoteCheckButton extends ConsumerWidget {
  const NoteCheckButton({super.key, required this.noteId});
  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovered = ref.watch(_hoverNoteProvider(noteId));

    final isChecked = ref.watch(
      notesContextualActionBarController.select(
        (s) => s.selectedNotesIds.contains(noteId),
      ),
    );
    if (!isChecked && !isHovered) return const SizedBox.shrink();

    return Skeleton.ignore(
      child: IconButton(
        onPressed: () {
          ref
              .read(notesContextualActionBarController.notifier)
              .toggleNote(noteId);
        },
        icon: Icon(
          Icons.check_circle,
          size: 30,
          color: DarkColors.primary.withAlpha(isHovered ? 230 : 255),
        ),
      ),
    );
  }
}
