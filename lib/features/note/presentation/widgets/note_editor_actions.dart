import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors/colors.dart';
import '../../../../core/presentation/widgets/loading_widget.dart';
import '../controllers/editor_controller/editor_state.dart';
import '../controllers/note_providers.dart';

class EditorUndoAction extends ConsumerWidget {
  const EditorUndoAction({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final hasUndo = ref.watch(
      editorControllerProvider.select((s) => s.hasUndo),
    );

    return IconButton(
      onPressed: hasUndo
          ? ref.read(editorControllerProvider.notifier).undo
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
      editorControllerProvider.select((s) => s.hasRedo),
    );

    return IconButton(
      onPressed: hasRedo
          ? ref.read(editorControllerProvider.notifier).redo
          : null,
      icon: const Icon(Icons.redo_rounded, textDirection: TextDirection.ltr),
      tooltip: 'إعادة',
    );
  }
}

class IconWithText extends Equatable {
  const IconWithText({required this.icon, required this.label});

  final Widget icon;
  final String label;

  @override
  List<Object?> get props => [icon, label];
}

class SaveNoteButton extends ConsumerWidget {
  const SaveNoteButton({super.key});

  IconWithText? getChild(EditorState state) {
    if (state.isSaving) {
      return const IconWithText(
        icon: LoadingWidget(size: 15),
        label: 'جاري الحفظ...',
      );
    } else if (state.hasChanges) {
      return const IconWithText(
        icon: Icon(Icons.save_as_sharp),
        label: 'توجد تغييرات',
      );
    } else if (state.isSaved && state.hasUndo) {
      return const IconWithText(
        icon: Icon(Icons.check_sharp),
        label: 'تم الحفظ',
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context, ref) {
    final state = ref.watch(editorControllerProvider);
    final iconWithLabel = getChild(state);

    if (iconWithLabel == null) return const SizedBox.shrink();

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: DarkColors.primary.withOpacity(0.15),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        fixedSize: const Size.fromHeight(20),
      ),
      onPressed: !state.isSaved
          ? () {
              final formKey = ref.read(noteFormProvider).formKey;
              final isFormValid = formKey.currentState?.validate() ?? false;

              if (!isFormValid) return;
              ref.read(editorControllerProvider.notifier).saveChanges();
            }
          : null,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 2000),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: Row(
          spacing: 10,
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWithLabel.icon,
            Text(iconWithLabel.label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
