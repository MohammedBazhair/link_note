import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/constants/internal_constants/typedef.dart';
import '../../../../core/features/database/remote/remote_database_service.dart';
import '../../domain/entities/note.dart';

abstract interface class NotesRemoteDataSource {
  Future<Map<String, dynamic>> createNote(Note note);
  Future<void> insertNotes(Iterable<Note> notes);

  Future<List<Note>> readNotes(String ownerId);
  Future<Note?> getNoteById(String noteId);
  Stream<RowList> fetchNotesRealTime(String ownerId);
  Stream<Map<String, dynamic>?> fetchNoteStream(String noteId);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
}

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  NotesRemoteDataSourceImpl(this._database);
  final RemoteDatabaseService _database;

  final _notesTable = 'notes';
  final _idColumn = 'id';
  final _ownerColumn = 'owner_id';

  @override
  Future<Map<String, dynamic>> createNote(Note note) {
    return _database.insertRow(map: note.toMap(), table: _notesTable);
  }

  @override
  Future<List<Note>> readNotes(String ownerId) async {
    final mapList = await _database.readRowsWhere(
      filters: {'owner_id': ownerId},
      table: _notesTable,
    );
    final notes = mapList.map(Note.fromMap).toList();
    return notes;
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
    return _database.delete(id: id, column: _idColumn, table: _notesTable);
  }

  @override
  Stream<RowList> fetchNotesRealTime(String ownerId) {
    return _database.readRowsRealTime(
          table: _notesTable,
          primaryKey: [_idColumn],
          column: _ownerColumn,
          value: ownerId,
        )
        as Stream<RowList>;
  }

  @override
  Stream<Map<String, dynamic>?> fetchNoteStream(String noteId) {
    return _database
        .readRowsRealTime(
          table: ExternalConsts.notesTable,
          primaryKey: ['id'],
          column: 'id',
          value: noteId,
        )
        .map((rows) {
          if (rows == null || rows.isEmpty) return null;
          return rows.first;
        });
  }

  @override
  Future<void> insertNotes(Iterable<Note> notes) {
    final rows = notes.map((n) => n.toMap()).toList();
    return _database.insertRows(
      rows: rows,
      table: _notesTable,
      primaryKey: _idColumn,
    );
  }
  
  @override
  Future<Note?> getNoteById(String noteId) async{
    final map=await _database.readRow(id: noteId, column: _idColumn, table: _notesTable);
    if(map.isEmpty){
      return null;
    }
  return Note.fromMap(map);
  }
}
