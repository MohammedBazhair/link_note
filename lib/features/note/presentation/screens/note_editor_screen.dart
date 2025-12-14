import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors/colors.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../qr_code/presentation/screens/generate_qr_code_screen.dart';
import '../../../qr_code/presentation/screens/scanner_qr_code_screen.dart';
import '../../domain/entities/note.dart';
import '../controllers/note_controller.dart';
import '../widgets/editor_form.dart';
import '../widgets/save_dialog.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, this.note});
  final Note? note;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorState();
}

class _NoteEditorState extends ConsumerState<NoteEditorScreen> {
  bool anyChanges = false;
  final formKey = GlobalKey<FormState>();
  late final TextEditingController _noteTitleController;
  late final TextEditingController _noteContentController;

  bool get isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _noteTitleController = TextEditingController(
      text: widget.note?.title ?? '',
    );
    _noteContentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  @override
  void dispose() {
    _noteContentController.dispose();
    _noteTitleController.dispose();
    super.dispose();
  }

  bool get isFormValid => formKey.currentState?.validate() ?? false;

  Future<void> onSubmit() async {
    if (!isFormValid) return;
    final noteController = ref.read(noteControllerProvider.notifier);

    final note = Note(
      id: widget.note?.id,
      uuid: widget.note?.uuid,
      title: _noteTitleController.text,
      content: _noteContentController.text,
    );

    if (isEditing) {
      await noteController.updateNote(note);
    } else {
      await noteController.addNote(note);
    }
    context.pop();
  }

  Future<void> onGenerateQrSubmit() async {
    final isFormValid = formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;

    final title = _noteTitleController.text;
    final content = _noteContentController.text;
    final note = Note(title: title, content: content);

    await context.pushTo(GenerateQrCodeScreen(data: note.toJson()));
  }

  Future<void> onPopInvoke() async {
    if (!isFormValid || !anyChanges) return context.pop();

    final isWantToSave = await showDialog<bool?>(
      context: context,
      builder: (context) => const SaveDialog(),
    );
    if (isWantToSave == null) return;

    isWantToSave ? await onSubmit() : context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await onPopInvoke();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: EditorForm(
                    titleController: _noteTitleController,
                    contentController: _noteContentController,
                    formKey: formKey,
                    onPopInvoke: onPopInvoke,
                    onEdited: (_) => anyChanges = true,
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  spacing: 20,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DarkColors.primary,
                        ),
                        onPressed: onGenerateQrSubmit,
                        child: const Text('Generate QR'),
                      ),
                    ),

                    if (!Platform.isWindows)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final scannedJson = await context.pushTo<String?>(
                              const ScannerQrCodeScreen(),
                            );
                            if (scannedJson?.isEmpty ?? true) return;
                            final note = Note.fromJson(scannedJson!);

                            _noteTitleController.text = note.title;
                            _noteContentController.text = note.content;
                          },
                          child: const Text('Scan QR'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
