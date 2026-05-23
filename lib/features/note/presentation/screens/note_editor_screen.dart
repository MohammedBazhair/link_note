import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/note.dart';
import '../controllers/note_providers.dart';
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
    final form = ref.read(noteFormProvider);

    ref.listenManual(editorHistoryControllerProvider, (_, next) {
      final editorContnet = next.editorContent;
      if (form.title.text != editorContnet.title) {
        form.title.text = editorContnet.title;
      }

      if (form.content.text != editorContnet.content) {
        form.content.text = editorContnet.content;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(editorFormControllerProvider.notifier).initForm(widget.note);
    });
  }

  GlobalKey<FormState> get formKey => ref.watch(noteFormProvider).formKey;

  bool get isFormValid => formKey.currentState?.validate() ?? false;

  Future<void> onSubmit() async {
    if (!isFormValid) return;
    final noteController = ref.read(noteControllerProvider.notifier);
    final form = ref.read(noteFormProvider);

    final note = Note(
      id: widget.note?.id,
      ownerId: widget.note?.ownerId,
      title: form.title.text,
      content: form.content.text,
      updatedAt: DateTime.now().toUtc(),
    );

    if (isEditing) {
      await noteController.updateNote(note);
    } else {
      await noteController.addNote(note);
    }
    context.pop();
  }

  Future<void> onPopInvoke() async {
    final anyChanges = ref
        .read(editorHistoryControllerProvider)
        .hasUndo;
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
      child: const Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: NoteFormHeader(),
        ),
        body: Padding(padding: EdgeInsets.all(18), child: EditorForm()),
      ),
    );
  }
}
