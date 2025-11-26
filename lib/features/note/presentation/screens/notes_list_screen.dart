import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link_note/features/note/domain/entities/note.dart';
import 'package:link_note/features/note/presentation/screens/note_editor.dart';
import 'package:link_note/features/note/services/notes_service.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  void loadNotes() async {
    notes = await NotesService().read();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes')),
      body: notes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: EdgeInsets.all(24),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
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
                      final isDeleted = await Navigator.push<bool>(
                        context,
                        CupertinoModalPopupRoute(
                          builder: (context) => NoteEditor(note),
                        ),
                      );

                      if (isDeleted == null || !isDeleted) return;
                      notes.remove(note);
                      setState(() {});
                    },
                  ),
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 10),
            ),
    );
  }
}
