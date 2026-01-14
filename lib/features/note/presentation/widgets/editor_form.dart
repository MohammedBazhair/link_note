import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../qr_code/presentation/screens/generate_qr_code_screen.dart';
import '../../../qr_code/presentation/screens/scanner_qr_code_screen.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_popup_action.dart';
import '../controllers/note_controller/note_controller.dart';
import '../controllers/note_controller/note_form_state.dart';
import 'content_form_field.dart';
import 'title_form_field.dart';

final editorFormProvider = StateProvider((ref) {
  final state = EditorFormState();

  ref.onDispose(state.dispose);

  return state;
});

class EditorForm extends ConsumerWidget {
  const EditorForm({super.key, required this.onPopInvoke});

  final VoidCallback onPopInvoke;

  @override
  Widget build(BuildContext context, ref) {
    final formState = ref.read(editorFormProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Form(
        key: formState.formKey,

        child: Column(
          spacing: 24,
          children: [
            NoteFormHeader(onBack: onPopInvoke),
            Expanded(
              child: ContentFormField(
                controller: formState.contentController,
                onChanged: (value) => formState.markedChanges(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoteFormHeader extends ConsumerWidget {
  const NoteFormHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, ref) {
    final formState = ref.read(editorFormProvider);

    return Row(
      children: [
        IconButton(
          iconSize: 32,
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: TitleFormField(
            controller: formState.titleController,
            onChanged: (value) => formState.markedChanges(),
          ),
        ),
        PopupMenuButton<NotePopupAction>(
          onSelected: (action) async {
            switch (action) {
              case NotePopupAction.qrGenerator:
                if (Platform.isWindows) {
                  return context.showSnakbar('هذه الميزة لاتعمل على ويندوز');
                }
                final noteJson = formState.note.toJson();
                await context.pushTo(GenerateQrCodeScreen(data: noteJson));

              case NotePopupAction.qrScanner:
                final data = await context.pushTo<String?>(
                  const ScannerQrCodeScreen(),
                );
                if (data == null) return;
                final note = Note.fromJson(data);
                formState.initForm(note);
                formState.markedChanges();
              case NotePopupAction.deleteNote:
                final note = formState.note;
                if (note.id == null) return context.pop();

                await ref
                    .read(noteControllerProvider.notifier)
                    .deleteNote(note);
                context.pop();
            }
          },
          itemBuilder: (context) => NotePopupAction.values
              .map(
                (value) => PopupMenuItem<NotePopupAction>(
                  value: value,

                  child: Row(
                    children: [
                      Icon(value.icon),
                      const SizedBox(width: 10),
                      Text(value.label),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
