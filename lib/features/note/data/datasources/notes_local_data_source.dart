import 'dart:async';

import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/constants/internal_constants/log.dart';
import '../../../../core/constants/internal_constants/typedef.dart';
import '../../../../core/features/database/local/cache_service.dart';
import '../../../../core/features/database/local/local_database_service.dart';
import '../../../../core/features/sync/sync_change_model.dart';
import '../../../../core/features/sync/sync_local_data_source.dart';
import '../../domain/entities/note.dart';

abstract interface class NotesLocalDataSource {
  Future<int> createNote({required Note note, bool skipLocalTracking = false});
  Future<void> insertNotes(Iterable<Note> notes);
  Future<List<Note>> readNotes();
  Future<Note?> getNoteById(String id);
  Stream<RowList> fetchNotesRealTime();
  Future<void> updateNote({required Note note, bool skipLocalTracking = false});
  Future<void> deleteNote({required String id, bool skipLocalTracking = false});
}

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  NotesLocalDataSourceImpl(this._db, this._cache, this._syncLocal);
  final LocalDatabaseService _db;
  final LocalCacheService _cache;
  final SyncLocalDataSource _syncLocal;

  final _notesTable = ExternalConsts.notesTable;
  final _idColumn = 'id';
  final _ownerColumn = 'owner_id';

  @override
  Future<int> createNote({
    required Note note,
    bool skipLocalTracking = false,
  }) async {
    final result = await _db.insertRow(map: note.toMap(), table: _notesTable);
    final noteId = note.id;

    Logger.log(message: noteId);
    if (skipLocalTracking || noteId == null) return result;

    final change = SyncChangeModel.create(
      tableName: _notesTable,
      recordId: noteId,
      operation: SyncOperation.insert,
    );
    unawaited(_syncLocal.addChange(change));

    return result;
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
  Future<void> updateNote({
    required Note note,
    bool skipLocalTracking = false,
  }) async {
    final noteId = note.id;
    if (noteId == null) return;

    await _db.update(
      updated: note.toMap(),
      value: note.id,
      column: _idColumn,
      table: _notesTable,
    );

    if (skipLocalTracking) return;

    final change = SyncChangeModel.create(
      tableName: _notesTable,
      recordId: noteId,
      operation: SyncOperation.update,
    );
    await _syncLocal.addChange(change);
  }

  @override
  Future<void> deleteNote({
    required String id,
    bool skipLocalTracking = false,
  }) async {
    final updatedAt = DateTime.now().toUtc().toIso8601String();
    
    await _db.update(
      updated: {'is_deleted': 1, 'updated_at': updatedAt},
      column: _idColumn,
      value: id,
      table: _notesTable,
    );

    if (skipLocalTracking) return;

    final change = SyncChangeModel.create(
      tableName: _notesTable,
      recordId: id,
      operation: SyncOperation.delete,
    );
    await _syncLocal.addChange(change);
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

  @override
  Future<Note?> getNoteById(String id) async {
    try {
      final rows = await _db.readRowsWhere(
        table: ExternalConsts.notesTable,
        filters: {'id': id},
      );
      return rows.isNotEmpty ? Note.fromMap(rows.first) : null;
    } catch (e, st) {
      Logger.log(error: e, stackTrace: st);
      return null;
    }
  }
}
