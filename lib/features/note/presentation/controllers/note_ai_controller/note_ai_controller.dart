import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/repositories/note_ai_repository.dart';
import 'note_ai_state.dart';

class NoteAiController extends StateNotifier<NoteAiState> {
  NoteAiController(this._serviceAi) : super(NoteAiState());
  final NoteAiRepository _serviceAi;

  Future<String> improveContent(String note) async {
    state = state.copyWith(isContentProcessing: true);

    try {
      final result = await _serviceAi.improveNoteContent(note);

      return result.text;
    } catch (e) {
      return note;
    } finally {
      _resetState();
    }
  }

  Future<String> improveTitle(Note note) async {
    state = state.copyWith(isTitleProcessing: true);

    try {
      final result = await _serviceAi.improveNoteTitle(note);

      return result.text;
    } catch (e) {
      debugPrint(e.toString());
      return note.title;
    } finally {
      _resetState();
    }
  }

  void _resetState() {
    state = state.copyWith(
      isContentProcessing: false,
      isTitleProcessing: false,
    );
  }
}
