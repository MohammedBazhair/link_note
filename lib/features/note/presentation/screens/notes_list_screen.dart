import 'package:flutter/material.dart';
import 'package:link_note/features/note/domain/entities/note.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen(this.notes, {super.key});
  final List<Note> notes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes')),
      body: ListView.separated(
        padding: EdgeInsets.all(24),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            color: const Color.fromARGB(255, 4, 63, 82),
            child: ListTile(
              title: Text(note.title),
              subtitle: Text(note.content, overflow: TextOverflow.ellipsis),
              onTap: () {},
            ),
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 10),
      ),
    );
  }
}
