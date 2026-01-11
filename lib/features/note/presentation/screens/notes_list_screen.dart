import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/widgets/conditional_builder.dart';
import '../../../../core/presentation/widgets/custom_drawer.dart';
import '../../../../core/presentation/widgets/floating_actions_buttons.dart';
import '../../domain/entities/note.dart';
import '../controllers/note_controller/note_controller.dart';
import '../widgets/note_tile.dart';
import '../widgets/notes_widget.dart';
import '../widgets/nothing_note.dart';

final isInNotesListScreen = StateProvider((_) => false);

class NotesListScreen extends ConsumerStatefulWidget {
  const NotesListScreen({super.key});

  @override
  ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends ConsumerState<NotesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(isInNotesListScreen.notifier).update((_) => true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: NotesListAppBar(),
      ),
      drawer: CustomDrawer(),
      floatingActionButton: FloatingActionsButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: NotesStreamBuilder(),
    );
  }
}

class NotesListAppBar extends ConsumerWidget {
  const NotesListAppBar({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isSelectable = ref.watch(
      selectableNoteProvider.select((s) => s.isSelectable),
    );

    return AppBar(
      title: isSelectable ? const Text('حدد ملاحظة') : const Text('الملاحظات'),
      leading: isSelectable
          ? TextButton.icon(
              label: const Text('تم'),
              onPressed: context.pop,
              icon: const Icon(Icons.check),
            )
          : null,
      actions: [
        if (!isSelectable && Platform.isWindows)
          IconButton(
            hoverColor: Colors.transparent,

            onPressed: () async {
              await ref.read(noteControllerProvider.notifier).fetchNotes();
            },
            icon: const Icon(Icons.refresh),
          ),
      ],
    );
  }
}

class NotesStreamBuilder extends ConsumerStatefulWidget {
  const NotesStreamBuilder({super.key});

  @override
  ConsumerState<NotesStreamBuilder> createState() => _NotesStreamBuilderState();
}

class _NotesStreamBuilderState extends ConsumerState<NotesStreamBuilder> {
  late final Stream<List<Note>> notesStream;

  @override
  void initState() {
    super.initState();
    final controller = ref.read(noteControllerProvider.notifier);
    controller.fetchNotesRealTime();
    notesStream = controller.notesStream;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Note>>(
      stream: notesStream,
      builder: (context, snapshot) {
        final notes = snapshot.data ?? [];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return NotesListView(
            notes: List.generate(
              8,
              (_) => Note(
                title: 'Title Testing',
                content: 'Content' * 6,
                updatedAt: DateTime.now(),
              ),
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
