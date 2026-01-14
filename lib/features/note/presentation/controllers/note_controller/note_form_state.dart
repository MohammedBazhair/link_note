import 'package:flutter/material.dart';

import '../../../domain/entities/note.dart';

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

  void initForm([Note? note]) {
    if (note == null) return _clearForm();
    _hasChanges = false;
    _note = note;

    titleController.text = _note?.title ?? '';
    contentController.text = _note?.content ?? '';
  }

  void _clearForm() {
    _note = null;
    _hasChanges = false;

    titleController.clear();
    contentController.clear();
  }

  Note get note =>
      _note?.copyWith(
        title: titleController.text,
        content: contentController.text,
      ) ??
      Note(
        updatedAt: DateTime.now().toUtc(),
        title: titleController.text,
        content: contentController.text,
      );

  void dispose() {
    titleController.dispose();
    contentController.dispose();
  }

  void syncWith(Note note) {
    if (this.note.id == note.id &&
        titleController.text == note.title &&
        contentController.text == note.content) {
      return;
    }

    _note = note;
    titleController.text = note.title;
    contentController.text = note.content;
  }
}
