import 'package:flutter/material.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/note.dart';
import '../screens/note_editor.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({super.key, required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note.title.isEmpty ? 'No Title' : note.title, maxLines: 1),
      subtitle: Text(note.content, maxLines: 1),

      onTap: () => context.pushTo(NoteEditor(note: note)),
    );
  }
}
