import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/internal_constants/log.dart';
import '../../../../../core/utils/undo_redo_history.dart';
import '../../../domain/entities/editor_content.dart';
import 'editor_history_state.dart';

class EditorHistoryController extends Notifier<EditorHistoryState> {
  final _history = UndoRedoHistory<EditorContent>();

  Timer? _debounce;
  EditorContent? _snapshot;

  @override
  EditorHistoryState build() {
    Logger.log(message: 'build EditorHistoryController');

    ref.onDispose(() {
      Logger.log(message: 'dispose EditorHistoryController');
    });
    return const EditorHistoryState();
  }

  void initContent(EditorContent editorContent) {
    state = state.copyWith(editorContent: editorContent);
  }

  void edit({String? title, String? content}) {
    final currentEditorContent = state.editorContent;
    final newEditorContent = state.editorContent.copyWith(
      title: title,
      content: content,
    );

    if (currentEditorContent == newEditorContent) return;

    _snapshot ??= currentEditorContent;
    state = state.copyWith(editorContent: newEditorContent);

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_snapshot != currentEditorContent) _history.push(_snapshot!);

      _snapshot = null;
    });
  }

  void commit() {
    _debounce?.cancel();

    if (_snapshot == null) return;

    _history.push(_snapshot!);

    state = state.copyWith(
      hasRedo: _history.canRedo,
      hasUndo: _history.canUndo,
    );

    _snapshot = null;
  }

  void undo() {
    commit();

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
}
