// ignore_for_file: unawaited_futures

import 'dart:async';

import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/constants/internal_constants/log.dart';
import '../../../../core/constants/internal_constants/typedef.dart';
import '../../../../core/features/database/local/local_database_service.dart';
import '../../../../core/features/sync/sync_change_model.dart';
import '../../../../core/features/sync/sync_local_data_source.dart';
import '../../domain/entities/note.dart';

abstract interface class NotesLocalDataSource {
  Future<int> createNote({required Note note, bool skipLocalTracking = false});
  Future<void> insertNotes(Iterable<Note> notes);
  Future<List<Note>> readNotes({
    bool includeDeleted = true,
    required String ownerId,
  });
  Future<Note?> getNoteById(String id);
  Stream<RowList> fetchNotesRealTime(String ownerId);
  Future<void> updateNote({required Note note, bool skipLocalTracking = false});
  Future<void> deleteNote({required String id, bool skipLocalTracking = false});
  Future<void> deleteNotes({
    required Set<String> ids,
    bool skipLocalTracking = false,
  });

  Future<List<Note>> searchNotes({
    required String query,
    required String? ownerId,
  });
}

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  NotesLocalDataSourceImpl(this._db, this._syncLocal);
  final LocalDatabaseService _db;
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
    _syncLocal.addChange(change);

    return result;
  }

  @override
  Future<List<Note>> readNotes({
    bool includeDeleted = true,
    required String ownerId,
  }) async {
    try {
      final where = includeDeleted
          ? 'owner_id = ?'
          : 'owner_id = ? AND is_deleted = 0';
      const orderBy = 'updated_at DESC';

      final mapList = await _db.readRows(
        table: _notesTable,
        orderBy: orderBy,
        where: where,
        whereArgs: [ownerId],
      );
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
    _syncLocal.addChange(change);
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
    _syncLocal.addChange(change);
  }

  @override
  Stream<RowList> fetchNotesRealTime(String ownerId) {
    return _db.readRowsRealTime(
      table: _notesTable,
      where: 'owner_id = ?',
      whereArgs: [ownerId],
    );
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

  @override
  Future<void> deleteNotes({
    required Set<String> ids,
    bool skipLocalTracking = false,
  }) async {
    if (ids.isEmpty) return;

    final updatedAt = DateTime.now().toUtc().toIso8601String();

    await _db.updateMany(
      updated: {'is_deleted': 1, 'updated_at': updatedAt},
      column: _idColumn,
      valuesIn: ids.toList(),
      table: _notesTable,
    );

    if (skipLocalTracking) return;

    Future.forEach(ids, (id) {
      final change = SyncChangeModel.create(
        tableName: _notesTable,
        recordId: id,
        operation: SyncOperation.delete,
      );
      _syncLocal.addChange(change);
    });
  }

  @override
  Future<List<Note>> searchNotes({
    required String query,
    required String? ownerId,
  }) async {
    final rows = await _db.readRows(
      table: _notesTable,
      where:
          '''
      is_deleted = 0 AND $_ownerColumn = ? AND 
      (LOWER(title) LIKE LOWER(?) OR LOWER(content) LIKE LOWER(?)) 
     ''',
      whereArgs: [ownerId, query, query],
    );

    final notes = rows.map(Note.fromMap);

    return notes.toList();
  }
}
