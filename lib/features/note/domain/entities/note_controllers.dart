import 'package:flutter/material.dart';

import 'note.dart';

class NoteFormControllers {
  NoteFormControllers({
    this.id,
    required this.title,
    required this.content,
    required this.formKey,
  });

  final String? id;
  final TextEditingController title;
  final TextEditingController content;
  final GlobalKey<FormState> formKey;

  Note get note {
    return Note(
      id: id,
      updatedAt: DateTime.now(),
      title: title.text,
      content: content.text,
    );
  }

  void syncWith(Note note) {
    title.text = note.title;
    content.text = note.content;
  }

  void clearControllers() {
    title.clear();
    content.clear();
  }

  void dispose() {
    title.dispose();
    content.dispose();
  }

  NoteFormControllers copyWith({
    String? id,
    TextEditingController? title,
    TextEditingController? content,
    GlobalKey<FormState>? formKey,
  }) {
    return NoteFormControllers(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      formKey: formKey ?? this.formKey,
    );
  }
}
