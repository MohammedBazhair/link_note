import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/core/extensions/extensions.dart';
import 'package:link_note/features/note/domain/entities/note.dart';
import 'package:link_note/features/note/domain/entities/note_popup_action.dart';
import 'package:link_note/features/note/presentation/controllers/note_providers.dart';
import 'package:link_note/features/note/presentation/widgets/credits_widget.dart';
import 'package:link_note/features/note/presentation/widgets/note_editor_actions.dart';
import 'package:link_note/features/qr_code/presentation/screens/generate_qr_code_screen.dart';
import 'package:link_note/features/qr_code/presentation/screens/scanner_qr_code_screen.dart';
import 'content_form_field.dart';
import 'title_form_field.dart';

class EditorForm extends ConsumerWidget {
  const EditorForm({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final form = ref.watch(noteFormProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Form(
        key: form.formKey,

        child: const Column(
          spacing: 24,
          children: [
            TitleFormField(),

            Expanded(child: ContentFormField()),
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
    final controller = ref.read(currentNoteControllerProvider.notifier);
    const bigSpacing = 10.0;
    const smallSpacing = 8.0;
    return AppBar(
      actions: [
        const SaveNoteButton(),
        const SizedBox(width: bigSpacing),
        const EditorRedoAction(),
        const SizedBox(width: smallSpacing),
        const EditorUndoAction(),
        const SizedBox(width: bigSpacing),
        const CreditsWidget(),
        const SizedBox(width: bigSpacing),
        PopupMenuButton<NotePopupAction>(
          onSelected: (action) async {
            switch (action) {
              case NotePopupAction.qrGenerator:
                if (Platform.isWindows) {
                  return context.showSnakbar('هذه الميزة لاتعمل على ويندوز');
                }
                final qrData = controller.generateQrData();

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
                controller.loadNote(note:  note);
              case NotePopupAction.deleteNote:
                final isDeleted = await controller.deleteNote();
                if (isDeleted) return context.pop();
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
