import '../entities/note.dart';

abstract interface class NotesRepository {
  Future<void> create(Note note);
  Future<Set<Note>> getAll();
  Stream  fetchNotesRealTime();

  Future<void> update(Note note);
  Future<void> delete(String id);
}
