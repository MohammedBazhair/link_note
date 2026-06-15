import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../constants/external_constants/external_constants.dart';
import '../../constants/internal_constants/log.dart';
import '../database/local/local_database_service.dart';
import 'sync_change_model.dart';
import 'sync_state_model.dart';

abstract class SyncLocalDataSource {
  Future<void> addChange(SyncChangeModel change);
  Future<void> addChanges(List<SyncChangeModel> changes);

  Future<List<SyncChangeModel>> getTableChanges(String table);

  Future<void> deleteChange(int id);

  Future<void> clearTablesChanges(String table);

  Future<void> saveLastSynced(SyncStateModel state);

  Future<SyncStateModel?> getLastSynced(String tableName);
}

class SyncLocalDataSourceImpl implements SyncLocalDataSource {
  SyncLocalDataSourceImpl(this._db);
  final LocalDatabaseService _db;

  @override
  Future<void> addChange(SyncChangeModel change, {Batch? batch}) async {
    final existing = await _db.readRowsWhere(
      table: ExternalConsts.syncChangesTable,
      filters: {'table_name': change.tableName, 'record_id': change.recordId},
    );

    if (existing.isEmpty && batch == null) {
      await _db.insertRow(
        table: ExternalConsts.syncChangesTable,
        map: change.toMap(),
      );
      return;
    } else if (existing.isEmpty && batch != null) {
      batch.insert(ExternalConsts.syncChangesTable, change.toMap());
      return;
    }

    final oldChange = SyncChangeModel.fromMap(existing.first);

    SyncOperation newOperation = change.operation;

    if (oldChange.operation == SyncOperation.insert &&
        change.operation == SyncOperation.delete) {
      await deleteChange(oldChange.id!, batch: batch);
      return;
    }

    if (oldChange.operation == SyncOperation.insert &&
        change.operation == SyncOperation.update) {
      newOperation = SyncOperation.insert;
    }

    if (oldChange.operation == SyncOperation.update &&
        change.operation == SyncOperation.update) {
      newOperation = SyncOperation.update;
    }

    final updatedValues = {'operation': newOperation.name};

    if (batch == null) {
      await _db.update(
        table: ExternalConsts.syncChangesTable,
        updated: updatedValues,
        column: 'id',
        value: oldChange.id,
      );
    } else {
      batch.update(
        ExternalConsts.syncChangesTable,
        updatedValues,
        where: 'id = ?',
        whereArgs: [oldChange.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  @override
  Future<List<SyncChangeModel>> getTableChanges(String table) async {
    try {
      final maps = await _db.readRowsWhere(
        table: 'sync_changes',
        filters: {'table_name': table},
      );

      return maps.map(SyncChangeModel.fromMap).toSet().toList();
    } catch (e, st) {
      Logger.log(error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<void> deleteChange(int id, {Batch? batch}) async {
    if (batch == null) {
      await _db.deleteWhere(
        table: ExternalConsts.syncChangesTable,
        filters: {'id': id},
      );
    } else {
      batch.delete(
        ExternalConsts.syncChangesTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  @override
  Future<void> clearTablesChanges(String table) async {
    await _db.deleteWhere(
      table: 'sync_changes',
      filters: {'table_name': table},
    );
  }

  @override
  Future<void> saveLastSynced(SyncStateModel state) async {
    final existing = await getLastSynced(state.tableName);

    if (existing != null) {
      await _db.update(
        table: 'sync_state',
        updated: state.toMap(),
        column: 'table_name',
        value: state.tableName,
      );
    } else {
      await _db.insertRow(table: 'sync_state', map: state.toMap());
    }
  }

  @override
  Future<SyncStateModel?> getLastSynced(String tableName) async {
    final maps = await _db.readRowsWhere(
      table: 'sync_state',
      filters: {'table_name': tableName},
    );

    if (maps.isEmpty) return null;

    return SyncStateModel.fromMap(maps.first);
  }

  @override
  Future<void> addChanges(List<SyncChangeModel> changes) async {
    if (changes.isEmpty) return;

    final batch = _db.createBatch();

    await Future.wait(changes.map(addChange));

    await batch.commit(noResult: true);
  }
}
