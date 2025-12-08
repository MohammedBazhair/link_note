import '../../../../core/features/database/remote/database_service.dart';
import '../../domain/entities/note.dart';

abstract interface class NotesRemoteDataSource {
  Future<void> createNote(Note note);
  Future<Set<Note>> readNotes();
  Stream fetchNotesRealTime();
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
}

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  NotesRemoteDataSourceImpl(this._database);
  final RemoteDatabaseService _database;

  final _notesTable = 'notes';
  final _idColumn = 'id';

  @override
  Future<void> createNote(Note note) {
    return _database.insertRow(map: note.toMap(), table: _notesTable);
  }

  @override
  Future<Set<Note>> readNotes() async {
    final mapList = await _database.readRows(table: _notesTable);
    return mapList.map(Note.fromMap).toSet();
  }

  @override
  Future<void> updateNote(Note note) {
    if (note.id == null) return Future.value();
    return _database.update(
      updated: note.toMap(),
      id: note.id!,
      column: _idColumn,
      table: _notesTable,
    );
  }

  @override
  Future<void> deleteNote(String id) {
    return _database.delete(id: id, column: _idColumn, table:_notesTable);
  }
  
  @override
  Stream fetchNotesRealTime() {
    return _database.readRowsRealTime(table: _notesTable, primaryKey: [_idColumn]);
  }
}
