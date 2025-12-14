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
    final userId = ref.read(userControllerProvider).profile.userId;
    final isSelectable = ref.watch(
      selectableNoteProvider.select((s) => s.isSelectable),
    );
    final notesAsync = ref.watch(notesStreamProvider(userId));
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

      body: notesAsync.when(
        data: (notes) {
          return ConditionalBuilder(
            condition: notes.isNotEmpty,
            builder: (_) => NotesListView(notes: notes),
            fallback: (_) => const NothingNoteWidget(),
          );
        },
        loading: () {
          final fakeNotes = List.generate(
            8,
            (_) => Note(
              title: 'Title Testing',
              content: 'Content content content content content.',
            ),
          );

          return NotesListView(notes: fakeNotes,  isShimmerEnabled: true);
        },
        error: (_, __) => const NothingNoteWidget(),
      ),
    );
  }
}

