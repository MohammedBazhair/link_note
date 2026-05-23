import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/internal_constants/log.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/repositories/note_ai_repository.dart';
import '../note_providers.dart';
import 'note_ai_state.dart';

class NoteAiController extends Notifier<NoteAiState> {
   NoteAiRepository get _serviceAi=> ref.read(noteAiRepositoryProvider);

  @override
  NoteAiState build() => ResetAiNoteState();

  Future<String> improveContent(Note note) async {
    state = UpdatingAiNoteState(isContentProcessing: true);

    try {
      final result = await _serviceAi.improveNoteContent(note);

      state = SuccessAiNoteState();
      return result;
    } on AppException catch (e) {
      state = ShowMessageAiNoteState(message: e.message);
      return note.content;
    } on Exception catch (e, st) {
      _handleError(e, st);
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
      return result;
    } on AppException catch (e) {
      state = ShowMessageAiNoteState(message: e.message);
      return note.title;
    } on Exception catch (e, st) {
      _handleError(e, st);

      return note.title;
    } finally {
      _resetState();
    }
  }

  void _resetState() {
    state = ResetAiNoteState();
  }

  void _handleError(Exception e, StackTrace st) {
    state = ShowMessageAiNoteState(
      message: 'حدث خطأ غير متوقع، حاول مرة أخرى لاحقا',
    );
    Logger.log(error: e, stackTrace: st);
  }

}
