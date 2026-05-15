import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/constants/internal_constants/typedef.dart';
import '../../../../core/features/database/remote/remote_database_service.dart';
import '../../../../core/features/sync/sync_state_model.dart';
import '../../domain/entities/note.dart';

abstract interface class NotesRemoteDataSource {
  Future<Map<String, dynamic>> createNote(Note note);
  Future<void> upsertNotes(Iterable<Note> notes);

  Future<List<Note>> readNotes({
    required String ownerId,
    SyncStateModel? lastNotesSync,
  });
  Future<Note?> getNoteById(String noteId);
  Stream<RowList> fetchNotesRealTime(String ownerId);
  Stream<Map<String, dynamic>?> fetchNoteStream(String noteId);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
  Future<void> deleteNotes(List<String> ids);
}

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  NotesRemoteDataSourceImpl(this._database, this._client);
  final RemoteDatabaseService _database;
  final SupabaseClient _client;

  final _notesTable = 'notes';
  final _idColumn = 'id';
  final _ownerColumn = 'owner_id';

  @override
  Future<Map<String, dynamic>> createNote(Note note) {
    return _database.insertRow(map: note.toMap(), table: _notesTable);
  }

  @override
 Future<List<Note>> readNotes({
    required String ownerId,
    SyncStateModel? lastNotesSync,
  }) async {
    var query = _client.from(_notesTable).select().eq(_ownerColumn, ownerId);

    final lastSyncDate = lastNotesSync?.lastSynced.toIso8601String();

    if (lastSyncDate != null) {
      query = query.gt('updated_at', lastSyncDate);
    }

    final mapList = await query.order('updated_at');

    return mapList.map(Note.fromMap).toList();
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
          primaryKey: [_idColumn],
          column: _idColumn,
          value: noteId,
        )
        .map((rows) {
          if (rows == null || rows.isEmpty) return null;
          return rows.first;
        });
  }

  @override
  Future<void> upsertNotes(Iterable<Note> notes) {
    final rows = notes.map((n) => n.toMap()).toList();

    return _database.upsertRows(
      rows: rows,
      table: _notesTable,
      primaryKey: _idColumn,
    );
  }

  @override
  Future<Note?> getNoteById(String noteId) async {
    final map = await _database.readRow(
      id: noteId,
      column: _idColumn,
      table: _notesTable,
    );
    if (map.isEmpty) {
      return null;
    }
    return Note.fromMap(map);
  }

  @override
  Future<void> deleteNote(String id) {
    return _database.update(
      id: id,
      column: _idColumn,
      table: _notesTable,
      updated: {'is_deleted': 1},
    );
  }

  @override
  Future<void> deleteNotes(List<String> ids) {
    final updates = ids.map((id) => {'id': id, 'is_deleted': 1}).toList();

    return _database.upsertRows(
      rows: updates,
      table: _notesTable,
      primaryKey: _idColumn,
    );
  }
}
