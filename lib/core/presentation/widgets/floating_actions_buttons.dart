import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../features/note/presentation/controllers/current_note_controller/current_note_state.dart';
import '../../../features/note/presentation/controllers/note_providers.dart';
import '../../../features/note/presentation/screens/note_editor_screen.dart';
import '../../../features/session/presentation/screens/session_entry_screen.dart';
import '../../extensions/extensions.dart';

final isFloatingActiosClicked = StateProvider.autoDispose((ref) => false);

class FloatingActionsButtons extends ConsumerWidget {
  const FloatingActionsButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isClicked = ref.watch(isFloatingActiosClicked);
    final isSelectable = ref.watch(
      selectableNoteProvider.select((s) => s.isSelectable),
    );

    if (isSelectable) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          AnimatedOpacity(
            opacity: isClicked ? 1 : 0,
            duration: const Duration(milliseconds: 70),

            child: AnimatedSlide(
              duration: const Duration(milliseconds: 100),

              offset: Offset(0, isClicked ? 0 : 1),
              curve: Curves.bounceInOut,

              child: FloatingActionButton(
                heroTag: null,
                backgroundColor: Colors.blue.shade500,
                shape: const CircleBorder(),
                onPressed: () {
                  ref.read(isFloatingActiosClicked.notifier).state = false;
                  context.pushTo(const SessionEntryScreen());
                },
                tooltip: 'إدارة الجلسة',
                child: const Icon(Icons.settings_input_antenna_sharp),
              ),
            ),
          ),

          AnimatedOpacity(
            opacity: isClicked ? 1 : 0,
            duration: const Duration(milliseconds: 100),
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 150),

              offset: Offset(0, isClicked ? 0 : 1),
              curve: Curves.easeInOut,
              child: FloatingActionButton(
                heroTag: null,
                shape: const CircleBorder(),
                onPressed: () {
                  ref.read(isFloatingActiosClicked.notifier).state = false;
                  ref
                      .read(selectableNoteProvider.notifier)
                      .update((s) => s.copyWith(noteId: ''));
                  context.pushTo(const NoteEditorScreen(functionality: CurrentNoteFunctionality.add));
                },
                tooltip: 'إنشاء ملاحظة',
                child: const Icon(Icons.add_rounded),
              ),
            ),
          ),

          FloatingActionButton(
            heroTag: null,
            backgroundColor: isClicked ? Colors.red.shade300 : null,
            shape: const CircleBorder(),
            onPressed: () =>
                ref.read(isFloatingActiosClicked.notifier).update((state) => !state),

            child: isClicked
                ? const Icon(Icons.close_rounded)
                : const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}
