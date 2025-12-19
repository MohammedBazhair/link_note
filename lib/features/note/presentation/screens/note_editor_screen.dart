import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/extensions.dart';
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
  bool get isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();

    ref.read(editorFormProvider).initForm(widget.note);
  }

  GlobalKey<FormState> get formKey => ref.read(editorFormProvider).formKey;

  bool get isFormValid => formKey.currentState?.validate() ?? false;

  Future<void> onSubmit() async {
    if (!isFormValid) return;
    final noteController = ref.read(noteControllerProvider.notifier);
    final editorState = ref.read(editorFormProvider);

    final note = Note(
      id: widget.note?.id,
      uuid: widget.note?.uuid,
      title: editorState.titleController.text,
      content: editorState.contentController.text,
      updatedAt: DateTime.now()
    );

    if (isEditing) {
      await noteController.updateNote(note);
    } else {
      await noteController.addNote(note);
    }
    context.pop();
  }

  Future<void> onPopInvoke() async {
    final anyChanges = ref.read(editorFormProvider).hasChanges;
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
              children: [Expanded(child: EditorForm(onPopInvoke: onPopInvoke))],
            ),
          ),
        ),
      ),
    );
  }
}
