import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/repositories/note_ai_repository.dart';
import 'note_ai_state.dart';

final noteAiProvider =
    StateNotifierProvider.autoDispose<NoteAiController, NoteAiState>((ref) {
      return GetIt.I<NoteAiController>();
    });

class NoteAiController extends StateNotifier<NoteAiState> {
  NoteAiController(this._serviceAi) : super(NoteAiState());
  final NoteAiRepository _serviceAi;

  Future<void> improveContent(String note) async {
    state = state.copyWith(isContentProcessing: true);

    try {
      final result = await _serviceAi.improveNoteContent(note);

      state = state.copyWith(noteContent: result);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _resetState();
    }
  }

  Future<void> improveTitle(Note note) async {
    state = state.copyWith(isTitleProcessing: true);

    try {
      final result = await _serviceAi.improveNoteTitle(note);

      state = state.copyWith(noteTitle: result);
    } catch (e) {
      debugPrint(e.toString());
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
