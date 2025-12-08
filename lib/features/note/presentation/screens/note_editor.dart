import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors/colors.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../qr_code/presentation/screens/generate_qr_code_screen.dart';
import '../../../qr_code/presentation/screens/scanner_qr_code_screen.dart';
import '../../domain/entities/note.dart';
import '../controllers/note_controller.dart';

class NoteEditor extends ConsumerStatefulWidget {
  const NoteEditor({super.key, this.note});
  final Note? note;

  @override
  ConsumerState<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends ConsumerState<NoteEditor> {
  bool anyChanges = false;
  final formKey = GlobalKey<FormState>();
  late final TextEditingController noteTitleController;
  late final TextEditingController noteContentController;

  bool get isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    noteTitleController = TextEditingController(text: widget.note?.title ?? '');
    noteContentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  @override
  void dispose() {
    noteContentController.dispose();
    noteTitleController.dispose();
    super.dispose();
  }

  bool get isFormValid => formKey.currentState?.validate() ?? false;

  Future<void> onSubmit() async {
    if (!isFormValid) return;
    final noteController = ref.read(noteControllerProvider.notifier);

    final note = Note(
      id: widget.note?.id,
      uuid: widget.note?.uuid,
      title: noteTitleController.text,
      content: noteContentController.text,
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

    final noteContent = noteContentController.text;
    await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => GenerateQrCodeScreen(data: noteContent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (!isFormValid || !anyChanges) {
          context.pop();
          return;
        }

        final isWantToSave = await showDialog<bool?>(
          context: context,
          builder: (context) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(30),
              content: const Row(
                spacing: 10,
                children: [
                  Icon(Icons.info_outline_rounded),
                  Text('Do you want to save?'),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => context.pop(true),
                  child: const Text('Yes'),
                ),
                TextButton(
                  onPressed: () => context.pop(false),
                  child: const Text('No'),
                ),
              ],
            );
          },
        );
        if (isWantToSave == null) return;

        isWantToSave ? await onSubmit() : context.pop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: Form(
                    key: formKey,
                    child: Column(
                      spacing: 24,
                      children: [
                        TextFormField(
                          controller: noteTitleController,
                          maxLines: 2,
                          minLines: 1,
                          style: TextStyle(color: Colors.white.withAlpha(200)),
                          cursorColor: const Color(0x809CDEBC),
                          decoration: const InputDecoration(
                            hintText: 'Title...',
                          ),
                          onChanged: (value) => anyChanges = true,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: noteContentController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                            ),
                            cursorColor: const Color(0x809CDEBC),
                            decoration: const InputDecoration(
                              hintText: 'Enter Text Here...',
                            ),
                            onChanged: (value) => anyChanges = true,

                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return "Field Can't be Empty";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
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
                            final scannedNote = await Navigator.of(context)
                                .push<String>(
                                  MaterialPageRoute(
                                    builder: (_) => const ScannerQrCodeScreen(),
                                  ),
                                );
                            if (scannedNote?.isEmpty ?? true) return;
                            noteContentController.text = scannedNote ?? '';
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
