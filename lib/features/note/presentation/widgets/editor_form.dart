import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../qr_code/presentation/screens/generate_qr_code_screen.dart';
import '../../../qr_code/presentation/screens/scanner_qr_code_screen.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_popup_action.dart';
import '../controllers/note_form_state.dart';
import 'content_form_field.dart';
import 'title_form_field.dart';

final editorFormProvider = StateProvider((ref) {
  final state = EditorFormState();

  ref.onDispose(() {
    state.dispose();
    print('-------------------------');
    print('dispose form state');
    print('-------------------------');
  });

  return state;
});

class EditorForm extends ConsumerWidget {
  const EditorForm({super.key, required this.onPopInvoke});

  final VoidCallback onPopInvoke;

  @override
  Widget build(BuildContext context, ref) {
    final formState = ref.read(editorFormProvider);
    return Form(
      key: formState.formKey,
      child: Column(
        spacing: 24,
        children: [
          NoteFormHeader(onBack: onPopInvoke),
          Expanded(
            child: ContentFormField(controller: formState.contentController),
          ),
        ],
      ),
    );
  }
}

class NoteFormHeader extends ConsumerWidget {
  const NoteFormHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, ref) {
    final formState = ref.watch(editorFormProvider);

    return Row(
      children: [
        IconButton(
          iconSize: 32,
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 5),
        Expanded(child: TitleFormField(controller: formState.titleController)),
        PopupMenuButton(
          onSelected: (action) async {
            switch (action) {
              case NotePopupAction.qrGenerator:
                final noteJson = formState.note.toJson();
                await context.pushTo(GenerateQrCodeScreen(data: noteJson));

              case NotePopupAction.qrScanner:
                final data = await context.pushTo<String?>(
                  const ScannerQrCodeScreen(),
                );
                if (data == null) return;
                final note = Note.fromJson(data);
                formState.titleController.text = note.title;
                formState.contentController.text = note.content;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: NotePopupAction.qrGenerator,
              child: Text('Genereate Qr Code'),
            ),
            const PopupMenuItem(
              value: NotePopupAction.qrScanner,
              child: Text('Scanner Qr Code'),
            ),
          ],
        ),
      ],
    );
  }
}
