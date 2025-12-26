import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/repositories/note_ai_repository.dart';
import 'note_ai_state.dart';

final noteAiProvider =
    StateNotifierProvider.autoDispose<NoteAiController, NoteAiState>((ref) {
      return GetIt.I<NoteAiController>();
    });

class NoteAiController extends StateNotifier<NoteAiState> {
  NoteAiController(this._serviceAi) : super(NoteAiState());
  final NoteAiRepository _serviceAi;

  Future<void> improve(String note) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);

    try {
      final result = await _serviceAi.improveNote(note);

      if (!mounted) return;
      state = state.copyWith(result: result);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) state = state.copyWith(isLoading: false);
    }
  }

  @override
  void dispose() {
    print('dispose called');
    super.dispose();
  }
}
