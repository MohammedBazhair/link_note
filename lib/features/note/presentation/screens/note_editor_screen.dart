import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/note.dart';
import '../controllers/current_note_controller/current_note_state.dart';
import '../controllers/note_providers.dart';
import '../widgets/editor_form.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, this.note, required this.functionality});
  final Note? note;
  final CurrentNoteFunctionality functionality;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorState();
}

class _NoteEditorState extends ConsumerState<NoteEditorScreen> {
  @override
  void initState() {
    super.initState();
    final form = ref.read(noteFormProvider);

    ref.listenManual(editorControllerProvider, (_, next) {
      final editorContnet = next.editorContent;
      if (form.title.text != editorContnet.title) {
        form.title.text = editorContnet.title;
      }

      if (form.content.text != editorContnet.content) {
        form.content.text = editorContnet.content;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(currentNoteControllerProvider.notifier)
          .loadNote(note: widget.note, functionality: widget.functionality);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: NoteFormHeader(),
      ),
      body: Padding(padding: EdgeInsets.all(18), child: EditorForm()),
    );
  }
}
