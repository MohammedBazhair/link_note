import '../../../../core/errors/result.dart';
import '../entities/note.dart';

abstract class NoteAiRepository {
  Future<Result<String>> improveNoteContent(Note note);

  Future<Result<String>> improveNoteTitle(Note note);
}
