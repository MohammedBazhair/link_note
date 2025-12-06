import 'package:link_note/features/note/domain/entities/note.dart';

abstract interface class NotesRepository {
  Future<void> create(Note note);
  Future<Set<Note>> getAll();
  Future<void> update(Note note);
  Future<void> delete(String id);
}
