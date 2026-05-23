// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/undo_redo_history.dart';

class EditorHistoryController extends Notifier<EditorHistoryState> {
  final _history = UndoRedoHistory<EditorHistoryState>();

  Timer? _debounce;
  EditorHistoryState? _snapshot;

  @override
  EditorHistoryState build() {
    return const EditorHistoryState();
  }

  void edit({String? title, String? content}) {
    _snapshot ??= state;

    state = state.copyWith(title: title, content: content);

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_snapshot != state) _history.push(_snapshot!);

      _snapshot = null;
    });
  }

  void commit() {
    _debounce?.cancel();

    if (_snapshot == null) return;

    _history.push(_snapshot!);

    _snapshot = null;
  }

  void undo() {
    commit();

    final previous = _history.undo(state);

    if (previous != null) state = previous;
  }

  void redo() {
    final next = _history.redo(state);

    if (next != null) state =next;
  }


}

class EditorHistoryState extends Equatable {
  const EditorHistoryState({this.title = '', this.content = ''});
  final String title;
  final String content;

  EditorHistoryState copyWith({String? title, String? content}) {
    return EditorHistoryState(
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  @override
  List<Object?> get props => [title, content];
}
