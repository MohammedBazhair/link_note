import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/colors/colors.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/widgets/conditional_builder.dart';
import '../../../note/domain/entities/note.dart';
import '../../../note/presentation/controllers/note_providers.dart';
import '../../../note/presentation/screens/note_editor_screen.dart';
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
    return Card(
      clipBehavior: Clip.antiAlias,
      color: const Color(0xFF1E2230),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(width: 0.5, color: Colors.white.withOpacity(0.08)),
      ),
      child: InkWell(
        onTap: () => context.pushTo(NoteEditorScreen(note: note)),
        highlightColor: DarkColors.primary.withOpacity(0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 0.5,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    gradient: const RadialGradient(
                      center: AlignmentGeometry.bottomRight,
                      radius: 3,
                      colors: [
                        Color(0xFF405153),
                        Color(0xFF31474D),
                        Color(0xFF214650),
                      ],
                    ).withOpacity(0.5),
                  ),
                ),

                PositionedDirectional(
                  start: 18,
                  bottom: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0XFF18202C),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'محدد',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
                      fontSize: 18,
                      height: 2,
                      fontWeight: FontWeight.bold,
                      color: Color(0xE0FFFFFF),
                    ),
                  ),
                  Text(
                    note.content,
                    maxLines: 3,

                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: DarkColors.secondFont,
                    ),
                  ),
                  const Divider(
                    color: Color.fromARGB(88, 94, 94, 94),
                    thickness: 0.5,
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'آخر تعديل: ${note.lastUpdateText}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(157, 1, 183, 193),
                        ),
                      ),

                      SizedBox(
                        height: 30,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: DarkColors.primary,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          onPressed: () =>
                              context.pushTo(NoteEditorScreen(note: note)),
                          icon: const Icon(Icons.draw_rounded),
                          label: const Text('تعديل'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
