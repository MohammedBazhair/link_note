import '../entities/note.dart';

abstract interface class NotesRepository {
  Future<Note?> create(Note note);
  Future<List<Note>> getAll(String userId);
   Stream<List<Note>>  fetchNotesRealTime(String userId);
  Stream<Note?> fetchNoteStream(String noteId);

  Future<void> update(Note note);
  Future<void> delete(String id);
}
