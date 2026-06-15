import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/core/utils/debouncer.dart';
import '../../../../../core/constants/internal_constants/log.dart';
import '../../../../../core/utils/undo_redo_history.dart';
import '../../../domain/entities/editor_content.dart';
import '../current_note_controller/current_note_state.dart';
import '../note_providers.dart';
import 'editor_state.dart';

class EditorController extends Notifier<EditorState> {
  final _history = UndoRedoHistory<EditorContent>();

  EditorContent? _firstSnapshot;
  final _debounce = Debouncer(milliseconds: 500);
  EditorContent? _snapshot;

  @override
  EditorState build() {
    Logger.log(message: 'build EditorHistoryController');

    ref.onDispose(() {
      Logger.log(message: 'dispose EditorHistoryController');
    });
    return const EditorState(editorContent: EditorContent());
  }

  void loadContent(EditorContent editorContent) {
    _firstSnapshot = editorContent;
    state = state.copyWith(editorContent: editorContent);
  }

  void updateEditorContent({String? title, String? content}) {
    final currentEditorContent = state.editorContent;
    final newEditorContent = state.editorContent.copyWith(
      title: title,
      content: content,
    );

    if (currentEditorContent == newEditorContent) return;

    ref
        .read(currentNoteControllerProvider.notifier)
        .updateNote(newEditorContent);

    _snapshot ??= currentEditorContent;
    state = state.copyWith(
      editorContent: newEditorContent,
      hasChanges: true,
      isSaved: false,
    );

    _debounce.run(() {
      if (!ref.mounted) return;

      if (_snapshot != currentEditorContent) _history.push(_snapshot!);

      state = state.copyWith(
        hasRedo: _history.canRedo,
        hasUndo: _history.canUndo,
      );
      _snapshot = null;
      _checkSameInitialState();
      saveChanges();
    });
  }

  void commitSnapshot() {
    _debounce.dispose();

    if (_snapshot == null) return;

    _history.push(_snapshot!);

    state = state.copyWith(
      hasRedo: _history.canRedo,
      hasUndo: _history.canUndo,
    );

    _snapshot = null;
  }

  void undo() {
    commitSnapshot();

    final previous = _history.undo(state.editorContent);

    if (previous == null) return;

    state = state.copyWith(
      editorContent: previous,

      hasRedo: _history.canRedo,
      hasUndo: _history.canUndo,
    );
  }

  void redo() {
    final next = _history.redo(state.editorContent);

    if (next == null) return;

    state = state.copyWith(
      editorContent: next,
      hasRedo: _history.canRedo,
      hasUndo: _history.canUndo,
    );
  }

  Future<void> saveChanges() async {
    final noteController = ref.read(noteControllerProvider.notifier);

    final currentNoteState = ref.read(currentNoteControllerProvider);

    try {
      state = state.copyWith(isSaving: true);
      final controller = ref.read(currentNoteControllerProvider.notifier);
      switch (currentNoteState.currentNoteFunctionality) {
        case CurrentNoteFunctionality.add:
          final newNote = ref.read(noteFormProvider).note;
          final note = await noteController.addNote(newNote);
          ref
              .read(noteFormProvider.notifier)
              .update((s) => s.copyWith(id: note?.id));
          controller.loadNote(
            note: note,
            functionality: CurrentNoteFunctionality.edit,
          );

        case CurrentNoteFunctionality.edit:
          await noteController.updateNote(currentNoteState.note!);
      }

      state = state.copyWith(isSaved: true, hasChanges: false);
    } catch (e, st) {
      Logger.log(error: e, stackTrace: st);
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  void _checkSameInitialState() {
    final currentEditorContent = state.editorContent;
    if (currentEditorContent != _firstSnapshot) return;

    _history.clearHistory();

    state = EditorState(editorContent: currentEditorContent);
  }
}
