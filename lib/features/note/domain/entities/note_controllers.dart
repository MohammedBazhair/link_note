import 'package:flutter/material.dart';

import 'note.dart';

class NoteFormControllers {
  NoteFormControllers({
    required this.title,
    required this.content,
    required this.formKey,
  });

  final TextEditingController title;
  final TextEditingController content;
  final GlobalKey<FormState> formKey;

  void syncWith(Note note) {
    title.text = note.title;
    content.text = note.content;
  }

  void clearControllers() {
    title.clear();
    content.clear();
  }

  void dispose(void Function() listener) {
    title.removeListener(listener);
    content.removeListener(listener);

    title.dispose();
    content.dispose();
  }
}
