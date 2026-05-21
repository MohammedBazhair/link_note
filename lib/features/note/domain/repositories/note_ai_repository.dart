import '../entities/note.dart';

abstract class NoteAiRepository {
  Future<String> improveNoteContent(Note note);

  Future<String> improveNoteTitle(Note note);
}
