import '../entities/ai_response.dart';
import '../entities/note.dart';

abstract class NoteAiRepository {
  Future<AiResponseEntity> improveNoteContent(String note);

  Future<AiResponseEntity> improveNoteTitle(Note note);
}
