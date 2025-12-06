import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/core/extensions/extensions.dart';
import 'package:link_note/features/note/presentation/controllers/note_controller.dart';
import 'package:link_note/features/note/presentation/screens/note_editor.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes')),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () => context.pushTo(NoteEditor()),
        child: Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Consumer(
          builder: (context, ref, child) {
            final notes = ref.watch(noteControllerProvider);
            final noteController = ref.read(noteControllerProvider.notifier);
            if (notes.isEmpty) {
              return Center(
                child: Text(
                  'No notes available.\nTap the + button to add a new note.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return ListView.separated(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes.elementAt(index);
                return Card(
                  clipBehavior: Clip.antiAlias,
                  color: const Color(0xFF043F52),
                  child: ListTile(
                    title: Text(note.title),
                    subtitle: Text(
                      note.content,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () async {
                      final isDeleted = await context.pushTo<bool>(
                        NoteEditor(note: note),
                      );

                      if (isDeleted == null || !isDeleted) return;
                      await noteController.deleteNote(note);
                    },
                  ),
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 10),
            );
          },
        ),
      ),
    );
  }
}
