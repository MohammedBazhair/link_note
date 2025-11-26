import 'package:flutter/material.dart';
import 'package:link_note/features/note/domain/entities/note.dart';
import 'package:link_note/features/note/services/notes_service.dart';

class NoteEditor extends StatefulWidget {
  const NoteEditor(this.note, {super.key});
  final Note note;

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController noteTitleController;
  late final TextEditingController noteContentController;

  @override
  void initState() {
    super.initState();
    noteTitleController = TextEditingController(text: widget.note.title);
    noteContentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    noteContentController.dispose();
    noteTitleController.dispose();
    super.dispose();
  }

  Future<void> onSubmit() async {
    final isFormValid = formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;

    final updatedNote = widget.note.copyWith(
      title: noteTitleController.text,
      content: noteContentController.text,
    );

    await NotesService().update(updatedNote);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(24),
          shrinkWrap: true,
          children: [
            Form(
              key: formKey,
              child: Column(
                spacing: 50,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      IconButton.filled(
                        color: Colors.white,
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios_rounded),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: noteTitleController,
                          maxLines: 2,
                          minLines: 1,
                          style: TextStyle(color: Colors.white.withAlpha(200)),
                          cursorColor: const Color(0x809CDEBC),
                          decoration: InputDecoration(hintText: "Title..."),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return "Field Can't be Empty";
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          await NotesService().delete(widget.note);
                          if (context.mounted) Navigator.pop(context,true);
                        },
                        icon: Icon(Icons.delete_rounded),
                      ),
                    ],
                  ),

                  TextFormField(
                    controller: noteContentController,
                    maxLines: 14,
                    style: TextStyle(color: Colors.white.withAlpha(200)),
                    cursorColor: const Color(0x809CDEBC),
                    decoration: InputDecoration(hintText: "Enter Text Here..."),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return "Field Can't be Empty";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await onSubmit();
                if (context.mounted) Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
