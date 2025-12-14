import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/widgets/conditional_builder.dart';
import '../../../../core/presentation/widgets/custom_drawer.dart';
import '../../../../core/presentation/widgets/floating_actions_buttons.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import '../../domain/entities/note.dart';
import '../controllers/note_controller.dart';
import '../widgets/note_tile.dart';
import '../widgets/notes_widget.dart';
import '../widgets/nothing_note.dart';

class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isSelectable = ref.watch(
      selectableNoteProvider.select((s) => s.isSelectable),
    );

    return Scaffold(
      appBar: AppBar(
        title: isSelectable ? const Text('Select a Note') : const Text('Notes'),
        leading: isSelectable
            ? TextButton.icon(
                label: const Text('Done'),
                onPressed: context.pop,
                icon: const Icon(Icons.check),
              )
            : null,
      ),
      drawer: isSelectable ? null : const CustomDrawer(),
      floatingActionButton: isSelectable
          ? null
          : const FloatingActionsButtons(),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,

      body: const NotesStreamBuilder(),
    );
  }
}

class NotesStreamBuilder extends ConsumerWidget {
  const NotesStreamBuilder({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final controller = ref.read(noteControllerProvider.notifier);
    final userId = ref.read(
      userControllerProvider.select((s) => s.profile.userId),
    );
    ref.read(noteControllerProvider.notifier).fetchNotesRealTime(userId);


    return StreamBuilder<List<Note>>(
      stream: controller.notesStream,
      builder: (context, snapshot) {
        final notes = snapshot.data ?? [];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return NotesListView(
            notes: List.generate(
              8,
              (_) => Note(title: 'Title Testing', content: 'Content' * 6),
            ),
            isShimmerEnabled: true,
          );
        }

        return ConditionalBuilder(
          condition: notes.isNotEmpty,
          builder: (_) => NotesListView(notes: notes),
          fallback: (_) => const NothingNoteWidget(),
        );
      },
    );
  }
}
