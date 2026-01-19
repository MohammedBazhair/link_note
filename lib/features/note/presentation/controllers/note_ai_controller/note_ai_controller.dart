import 'package:flutter_riverpod/legacy.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/repositories/note_ai_repository.dart';
import 'note_ai_state.dart';

class NoteAiController extends StateNotifier<NoteAiState> {
  NoteAiController(this._serviceAi) : super(ResetAiNoteState());
  final NoteAiRepository _serviceAi;

  Future<String> improveContent(Note note) async {
    state = UpdatingAiNoteState(isContentProcessing: true);

    try {
      final result = await _serviceAi.improveNoteContent(note);

      state = SuccessAiNoteState();
      return result.value ?? note.content;
    } catch (e) {
      state = ShowMessageAiNoteState(message: e.toString());
      return note.content;
    } finally {
      _resetState();
    }
  }

  Future<String> improveTitle(Note note) async {
    state = UpdatingAiNoteState(isTitleProcessing: true);

    try {
      final result = await _serviceAi.improveNoteTitle(note);

      state = SuccessAiNoteState();
      return result.value ?? note.title;
    } catch (e) {
      state = ShowMessageAiNoteState(message: e.toString());
      return note.title;
    } finally {
      _resetState();
    }
  }

  void _resetState() {
    state = ResetAiNoteState();
  }
}
