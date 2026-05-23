import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors/colors.dart';
import '../controllers/note_providers.dart';

class EditorUndoAction extends ConsumerWidget {
  const EditorUndoAction({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final hasUndo = ref.watch(
      editorHistoryControllerProvider.select((s) => s.hasUndo),
    );

    return IconButton(
      onPressed: hasUndo
          ? ref.read(editorHistoryControllerProvider.notifier).undo
          : null,
      icon: const Icon(Icons.undo_rounded, textDirection: TextDirection.ltr),
      tooltip: 'تراجع',
    );
  }
}

class EditorRedoAction extends ConsumerWidget {
  const EditorRedoAction({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final hasRedo = ref.watch(
      editorHistoryControllerProvider.select((s) => s.hasRedo),
    );

    return IconButton(
      onPressed: hasRedo
          ? ref.read(editorHistoryControllerProvider.notifier).redo
          : null,
      icon: const Icon(Icons.redo_rounded, textDirection: TextDirection.ltr),
      tooltip: 'إعادة',
    );
  }
}

class SaveNoteButton extends ConsumerWidget {
  const SaveNoteButton({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final hasUndo = ref.watch(
      editorHistoryControllerProvider.select((s) => s.hasUndo),
    );
    
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: DarkColors.primary.withOpacity(0.15),
        foregroundColor: hasUndo ? Colors.white : DarkColors.secondFont,
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        fixedSize: const Size.fromHeight(20),
      ),
      onPressed: hasUndo
          ? () {
              final note = ref.read(editorFormControllerProvider);
              if (note == null) return;

              ref.read(noteControllerProvider.notifier).updateNote(note);
            }
          : null,
      icon: const Icon(Icons.save_rounded),
      label: hasUndo ? const Text('حفظ') : const Text('تم الحفظ'),
    );
  }
}
