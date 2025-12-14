import 'package:flutter/material.dart';

import 'content_form_field.dart';
import 'title_form_field.dart';

class EditorForm extends StatelessWidget {
  const EditorForm({
    super.key,
    required this.titleController,
    required this.contentController,
    required this.formKey,
    required this.onPopInvoke,
    required this.onEdited,
  });

  final TextEditingController titleController;
  final TextEditingController contentController;
  final GlobalKey<FormState> formKey;
  final VoidCallback onPopInvoke;
  final ValueChanged<String> onEdited;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        spacing: 24,
        children: [
          NoteFormHeader(
            onBack: onPopInvoke,
            titleController: titleController,
            onChanged: onEdited,
          ),
          Expanded(
            child: ContentFormField(
              controller: contentController,
              onChanged: onEdited,
            ),
          ),
        ],
      ),
    );
  }
}

class NoteFormHeader extends StatelessWidget {
  const NoteFormHeader({
    super.key,
    required this.onBack,
    required this.titleController,
    required this.onChanged,
  });

  final VoidCallback onBack;
  final TextEditingController titleController;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 7,
      children: [
        IconButton(
          iconSize: 32,
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        Expanded(
          child: TitleFormField(
            controller: titleController,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
