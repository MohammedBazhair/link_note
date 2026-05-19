import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/constants/internal_constants/log.dart';
import '../../../../core/features/database/local/cache_service.dart';
import '../../../../core/features/network/connectivity_service.dart';
import '../../../../core/features/sync/sync_change_model.dart';
import '../../../../core/features/sync/sync_local_data_source.dart';
import '../../../../core/features/sync/sync_state_model.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/sync_note_repository.dart';
import '../datasources/notes_local_data_source.dart';
import '../datasources/notes_remote_data_source.dart';

class SyncNoteRepositoryImpl implements SyncNoteRepository {
  SyncNoteRepositoryImpl(
    this._localCache,
    this._sync,
    this._connectivity,
    this._localNotes,
    this._remoteNotes,
  );

  final LocalCacheService _localCache;
  final ConnectivityService _connectivity;
  final SyncLocalDataSource _sync;
  final NotesLocalDataSource _localNotes;
  final NotesRemoteDataSource _remoteNotes;

  @override
  Future<void> syncAllNotes([String? userId]) async {
    final selectedUserId =
        userId ?? _localCache.getString(key: ExternalConsts.lastUserIdKey);

    if (selectedUserId == null) return;
    if (!await _connectivity.hasConnection()) return;
    await _pushNotesChanges();

    final lastNotesSync = await _sync.getLastSynced(ExternalConsts.notesTable);

    final remoteNotes = await _remoteNotes.readNotes(
      ownerId: selectedUserId,
      lastNotesSync: lastNotesSync,
    );

    await _localNotes.insertNotes(remoteNotes);

    final newDate = DateTime.now().toUtc();
    final newLastGlobalSync = SyncStateModel(
      tableName: ExternalConsts.notesTable,
      lastSynced: newDate,
    );
    await _sync.saveLastSynced(newLastGlobalSync);
  }

  Future<void> _pushNotesChanges() async {
    try {
      final storeNotesChanges = await _sync.getTableChanges('notes');

      final upserts = <Note>[];
      final deletes = <String>[];

      for (final change in storeNotesChanges) {
        final noteId = change.recordId;
        switch (change.operation) {
          case SyncOperation.delete:
            deletes.add(noteId);
          case SyncOperation.update:
          case SyncOperation.insert:
            final note = await _localNotes.getNoteById(noteId);
            if (note != null) upserts.add(note);
        }
      }

      if (upserts.isNotEmpty) {
        await _remoteNotes.upsertNotes(upserts);
      }

      if (deletes.isNotEmpty) {
        await _remoteNotes.deleteNotes(deletes);
      }

      await _sync.clearTablesChanges(ExternalConsts.notesTable);
    } catch (e, st) {
      Logger.log(error: e, stackTrace: st);
    }
  }
}
