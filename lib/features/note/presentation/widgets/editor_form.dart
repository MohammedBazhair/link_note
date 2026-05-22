import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/widgets/credits_widget.dart';
import '../../../qr_code/domain/entities/qr_data.dart';
import '../../../qr_code/presentation/screens/generate_qr_code_screen.dart';
import '../../../qr_code/presentation/screens/scanner_qr_code_screen.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_popup_action.dart';
import '../controllers/note_providers.dart';
import 'content_form_field.dart';
import 'title_form_field.dart';

class EditorForm extends ConsumerWidget {
  const EditorForm({super.key});

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
            TitleFormField(
              controller: formState.titleController,
              onChanged: (value) => formState.markedChanges(),
            ),

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
  const NoteFormHeader({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final formState = ref.read(editorFormProvider);

    return AppBar(
      actions: [
        const CreditsWidget(),
        const SizedBox(width: 10),
        const IconButton(
          onPressed: null,
          icon: Icon(Icons.redo_rounded, textDirection: TextDirection.ltr),
          tooltip: 'إعادة',
        ),
        const IconButton(
          onPressed: null,
          icon: Icon(Icons.undo_rounded, textDirection: TextDirection.ltr),
          tooltip: 'تراجع',
        ),
        PopupMenuButton<NotePopupAction>(
          onSelected: (action) async {
            switch (action) {
              case NotePopupAction.qrGenerator:
                if (Platform.isWindows) {
                  return context.showSnakbar('هذه الميزة لاتعمل على ويندوز');
                }
                final note = formState.note;
                final qrData = QrData(
                  name: note.title,
                  qrCodeRaw: note.toJson(),
                );

                await context.pushTo(GenerateQrCodeScreen(data: qrData));

              case NotePopupAction.qrScanner:
                if (Platform.isWindows) {
                  return context.showSnakbar('هذه الميزة لاتعمل على ويندوز');
                }
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
