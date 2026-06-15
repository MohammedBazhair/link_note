import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/colors/colors.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../note/presentation/controllers/current_note_controller/current_note_state.dart';
import '../../../note/presentation/controllers/note_providers.dart';
import '../../../note/presentation/screens/note_editor_screen.dart';
import '../../domain/entities/selected_note_preview_config.dart';

class SelectedNotePreview extends ConsumerWidget {
  const SelectedNotePreview({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final noteId = ref.watch(selectableNoteProvider).noteId;

    if (noteId == null) {
      return const _NoNoteSelected();
    }

    final asyncNote = ref.watch(getNoteByIdProvider(noteId));

    return asyncNote.when(
      data: (note) {
        if (note == null) return const _NoNoteSelected();

        final params = SelectedNotePreviewConfig(
          note: note,
          statusLabel: 'محدد',
          onButtonPressed: () => context.pushTo(
            NoteEditorScreen(
              note: note,
              functionality: CurrentNoteFunctionality.edit,
            ),
          ),
          onCardPressed: () => context.pushTo(
            NoteEditorScreen(
              note: note,
              functionality: CurrentNoteFunctionality.edit,
            ),
          ),
          textButtonLabel: 'تعديل',
          textButtonIcon: Icons.edit,
        );
        return SelectedNotePreviewCard(params);
      },
      loading: () {
        return Skeletonizer(
          child: SelectedNotePreviewCard(SelectedNotePreviewConfig.fake()),
        );
      },
      error: (_, __) {
        return const _NoNoteSelected();
      },
    );
  }
}

class _NoNoteSelected extends StatelessWidget {
  const _NoNoteSelected();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('لم يتم اختيار ملاحظة بعد'));
  }
}

class SelectedNotePreviewCard extends StatelessWidget {
  const SelectedNotePreviewCard(this.params, {super.key});
  final SelectedNotePreviewConfig params;

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
        onTap: params.onCardPressed,
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
                    child: Text(
                      params.statusLabel,
                      style: const TextStyle(
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
                    params.note.title,
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
                    params.note.content,
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
                        'آخر تعديل: ${params.note.lastUpdateText}',
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
                            textStyle: const TextStyle(height: 1),
                          ),
                          onPressed: params.onButtonPressed,
                          icon: Icon(params.textButtonIcon),
                          label: Text(params.textButtonLabel),
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
