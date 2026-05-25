import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/constants/colors/colors.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/providers/core_providers.dart';
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
    final isSelected =
        ref.watch(selectableNoteProvider.select((s) => s.noteId)) == note.id;
    final isHovered = ref.watch(_hoverNoteProvider(note.id));
    final borderColor = isHovered
        ? DarkColors.primary.withOpacity(0.3)
        : Colors.white.withOpacity(0.08);
    return InkWell(
      hoverColor: Colors.transparent,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      onTap: () {
        context.pushTo(
          NoteEditorScreen(
            functionality: CurrentNoteFunctionality.edit,
            note: note,
          ),
        );
      },
      onHover: (value) =>
          ref.read(_hoverNoteProvider(note.id).notifier).state = value,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            color: const Color(0xFF1E2230),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(width: 0.5, color: borderColor),
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

          if (isSelected || isHovered)
            PositionedDirectional(
              bottom: 0,
              end: 0,
              child: IconButton(
                onPressed: () {
                  ref
                      .read(selectionControllerProvider.notifier)
                      .toggle(note.id!);
                },
                icon: const Icon(
                  Icons.check_circle,
                  size: 30,
                  color: DarkColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
