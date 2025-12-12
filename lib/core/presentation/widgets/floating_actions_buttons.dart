import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../features/note/presentation/screens/note_editor.dart';
import '../../../features/session/presentation/screens/create_session_screen.dart';
import '../../extensions/extensions.dart';

final _isClicked = StateProvider.autoDispose((ref) => false);

class FloatingActionsButtons extends ConsumerWidget {
  const FloatingActionsButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isClicked = ref.watch(_isClicked);

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
                heroTag: 'create_session_fab',
                backgroundColor: Colors.blue.shade500,
                shape: const CircleBorder(),
                onPressed: () {
                  ref.read(_isClicked.notifier).state = false;
                  context.pushTo(const CreateSessionScreen());
                },
                tooltip: 'Create Session',
                child: const Icon(Icons.add_link_rounded),
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
                heroTag: 'create_note_fab',
                shape: const CircleBorder(),
                onPressed: () {
                  ref.read(_isClicked.notifier).state = false;

                  context.pushTo(const NoteEditor());
                },
                tooltip: 'Create Note',
                child: const Icon(Icons.add_rounded),
              ),
            ),
          ),

          FloatingActionButton(
            heroTag: 'main_fab',
            backgroundColor: isClicked ? Colors.red.shade300 : null,
            shape: const CircleBorder(),
            onPressed: () =>
                ref.read(_isClicked.notifier).update((state) => !state),

            child: isClicked
                ? const Icon(Icons.close_rounded)
                : const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}
