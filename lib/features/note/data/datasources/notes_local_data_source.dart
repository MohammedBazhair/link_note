import 'package:uuid/uuid.dart';

import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/constants/internal_constants/typedef.dart';
import '../../../../core/features/database/local/cache_service.dart';
import '../../../../core/features/database/local/local_database_service.dart';
import '../../domain/entities/note.dart';

abstract interface class NotesLocalDataSource {
  Future<int> createNote(Note note);
  Future<void> insertNotes(Iterable<Note> notes);
  Future<List<Note>> readNotes();
  Stream<RowList> fetchNotesRealTime();
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
}

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  NotesLocalDataSourceImpl(this._db, this._cache);
  final LocalDatabaseService _db;
  final LocalCacheService _cache;

  final _notesTable = ExternalConsts.notesTable;
  final _idColumn = 'id';
  final _ownerColumn = 'owner_id';

  @override
  Future<int> createNote(Note note) {
    final userId = _cache.getString(key: ExternalConsts.lastUserIdKey);
    final noteId=const Uuid().v4();
    final newNote = note.copyWith(
      id: note.id?? noteId,
      uuid: userId,
    );
    return _db.insertRow(map: newNote.toMap(), table: _notesTable);
  }

  @override
  Future<List<Note>> readNotes() async {
    try {
      final mapList = await _db.readRows(table: _notesTable);
      return mapList.map(Note.fromMap).toList();
    } catch (e) {
      return Future.value([]);
    }
  }

  @override
  Future<void> updateNote(Note note) {
    if (note.id == null) return Future.value();
    return _db.update(
      updated: note.toMap(),
      id: note.id!,
      column: _idColumn,
      table: _notesTable,
    );
  }

  @override
  Future<void> deleteNote(String id) {
    return _db.delete(id: id, column: _idColumn, table: _notesTable);
  }

  @override
  Stream<RowList> fetchNotesRealTime() {
    return _db.readRowsRealTime(table: _notesTable);
  }

  @override
  Future<void> insertNotes(Iterable<Note> notes) async {
    final rows = notes.map((n) => n.toMap()).toList();
    await _db.insertRows(rows: rows, table: _notesTable);
  }
}
