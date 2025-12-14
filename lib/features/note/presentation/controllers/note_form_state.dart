// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../../domain/entities/note.dart';

class EditorFormState {
  EditorFormState({this.anyChanges = false})
    : formKey = GlobalKey<FormState>(),
      titleController = TextEditingController(),
      contentController = TextEditingController();

  final bool anyChanges;
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController contentController;

  Note get note =>
      Note(title: titleController.text, content: contentController.text);

  EditorFormState copyWith({bool? anyChanges}) {
    return EditorFormState(anyChanges: anyChanges ?? this.anyChanges);
  }

  void dispose() {
    titleController.dispose();
    contentController.dispose();
  }
}
