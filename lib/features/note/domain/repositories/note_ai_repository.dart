import '../entities/ai_response.dart';

abstract class NoteAiRepository {
  Future<AiResponseEntity> improveNote(String note);
}
