import 'package:flutter/material.dart';
import 'package:link_note/features/note/domain/entities/note.dart';

class NoteEditor extends StatefulWidget {
  const NoteEditor({super.key, this.note});
  final Note? note;

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
    noteTitleController = TextEditingController(text: widget.note?.title ?? '');
    noteContentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
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

    // final updatedNote = widget.note.copyWith(
    //   title: noteTitleController.text,
    //   content: noteContentController.text,
    // );

    // await NotesService().update(updatedNote);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Do you want to save?'),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size.fromHeight(50),
                  ),
                  onPressed: () {},
                  child: Text('Yes'),
                ),
                TextButton(onPressed: () {}, child: Text('No')),
              ],
            );
          },
        );
      },
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(24),

            children: [
              Form(
                key: formKey,
                child: Column(
                  spacing: 30,
                  children: [
                    TextFormField(
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
                    SizedBox(
                      child: TextFormField(
                        controller: noteContentController,
                        maxLines: 14,
                        style: TextStyle(color: Colors.white.withAlpha(200)),
                        cursorColor: const Color(0x809CDEBC),
                        decoration: InputDecoration(
                          hintText: "Enter Text Here...",
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return "Field Can't be Empty";
                          }
                          return null;
                        },
                      ),
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
      ),
    );
  }
}
