import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/widgets/custom_drawer.dart';
import '../../domain/entities/note.dart';
import '../controllers/note_controller.dart';
import '../widgets/note_tile.dart';
import '../widgets/nothing_note.dart';
import 'note_editor.dart';

class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final height = MediaQuery.of(context).size.height * 0.8;

    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      drawer: const CustomDrawer(),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: () => context.pushTo(const NoteEditor()),
          child: const Icon(Icons.add_rounded),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: RefreshIndicator(
          color: const Color(0xFF0A978E),
          onRefresh: () async {
            await ref.read(noteControllerProvider.notifier).fetchNotes();
          },
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream:
                ref.read(noteControllerProvider.notifier).fetchNotesRealTime()
                    as Stream<List<Map<String, dynamic>>>,
            builder: (context, snapshot) {
              final notes = snapshot.data?.map(Note.fromMap).toSet() ?? {};

              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: height,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData || notes.isEmpty) {
                return NothingNoteWidget(height: height);
              }

              return ListView.separated(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes.elementAt(index);
                  return NoteTile(note: note);
                },
                separatorBuilder: (_, __) => const SizedBox(height: 10),
              );
            },
          ),
        ),
      ),
    );
  }
}
