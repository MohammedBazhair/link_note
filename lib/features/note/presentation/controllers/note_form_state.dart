import 'package:flutter/material.dart';

import '../../domain/entities/note.dart';

class EditorFormState {
  EditorFormState()
    : formKey = GlobalKey<FormState>(),
      titleController = TextEditingController(),
      contentController = TextEditingController();

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController contentController;

  Note? _note;
  bool _hasChanges = false;

  bool get hasChanges => _hasChanges;

  void markedChanges() => _hasChanges = true;

  void initForm(Note? note) {
    _hasChanges = false;
    if (note == null) return;
    _note = _note!.copyWith(
      id: note.id,
      uuid: note.uuid,
       title: note.title,
      content: note.content,
    );
    titleController.text = note.title;
    contentController.text = note.content;
  }

  Note? get note => _note?.copyWith(
    title: titleController.text,
    content: contentController.text,
  );

  void dispose() {
    titleController.dispose();
    contentController.dispose();
  }
}
