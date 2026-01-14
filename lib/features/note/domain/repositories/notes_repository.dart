import '../entities/note.dart';

abstract interface class NotesRepository {
  Future<Note?> create(Note note);
  Future<void> insertNotes(Iterable<Note> notes);
  Future<Note?> getNoteById(String noteId);
  Future<List<Note>> getAll();
  Stream<List<Note>> fetchNotesRealTime(String? userId);
  Stream<Note?> fetchNoteStream(String noteId);
  Future<void> syncNotes(String? userId);
  Future<void> update(Note note);
  Future<void> delete(Note note);
}
