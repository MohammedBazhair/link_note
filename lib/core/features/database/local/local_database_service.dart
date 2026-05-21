import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../constants/internal_constants/typedef.dart';

abstract interface class LocalDatabaseService {
  Future<int> insertRow({
    required Map<String, dynamic> map,
    required String table,
  });

  Future<void> insertRows({required RowList rows, required String table});

  Future<Map<String, dynamic>> readRow({
    required String id,
    required String column,
    required String table,
  });

  Future<List<Map<String, dynamic>>> readRowsWhere({
    required String table,
    required Map<String, Object> filters,
  });

  Future<List<Map<String, dynamic>>> readRows({
    required String table,
    String? orderBy,
    String? where,
    List<Object?>? whereArgs,
  });

  Stream<RowList> readRowsRealTime({required String table});

  Future<int> update({
    required Map<String, dynamic> updated,
    required dynamic value,
    required String column,
    required String table,
  });

  Future<int> delete({
    required String id,
    required String column,
    required String table,
  });

  Future<int> deleteWhere({
    required String table,
    required Map<String, Object> filters,
  });
}

class LocalDatabaseServiceImpl implements LocalDatabaseService {
  LocalDatabaseServiceImpl(this._database);
  final Database _database;

  @override
  Future<int> insertRow({
    required Map<String, dynamic> map,
    required String table,
  }) {
    return _database.insert(
      table,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<Map<String, dynamic>> readRow({
    required String id,
    required String column,
    required String table,
  }) async {
    final result = await _database.rawQuery(
      'SELECT * FROM $table WHERE $column = ?',
      [id],
    );
    return result.elementAtOrNull(0) ?? {};
  }

  @override
  Future<List<Map<String, dynamic>>> readRows({
    required String table,
    String? orderBy,
    String? where,
    List<Object?>? whereArgs,
  }) {
    return _database.query(
      table,
      orderBy: orderBy,
      where: where,
      whereArgs: whereArgs,
    );
  }

  @override
  Future<int> update({
    required Map<String, dynamic> updated,
    required dynamic value,
    required String column,
    required String table,
  }) {
    return _database.update(
      table,
      updated,
      where: '$column = ?',
      whereArgs: [value],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<int> delete({
    required String id,
    required String column,
    required String table,
  }) {
    return _database.delete(table, where: '$column = ?', whereArgs: [id]);
  }

  @override
  Future<int> deleteWhere({
    required String table,
    required Map<String, Object> filters,
  }) {
    final whereClause = filters.entries
        .map((e) => '${e.key} = ?')
        .join(' AND ');

    return _database.delete(
      table,
      where: whereClause,
      whereArgs: filters.values.toList(),
    );
  }

  @override
  Stream<RowList> readRowsRealTime({required String table}) {
    final future = readRows(table: table);
    return Stream.fromFuture(future);
  }

  @override
  Future<List<Map<String, dynamic>>> readRowsWhere({
    required String table,
    required Map<String, Object> filters,
  }) {
    final whereClause = filters.entries
        .map((e) => '${e.key} = ?')
        .join(' AND ');
    return _database.rawQuery(
      'SELECT * FROM $table WHERE $whereClause',
      filters.values.toList(),
    );
  }

  @override
  Future<void> insertRows({
    required RowList rows,
    required String table,
  }) async {
    final batch = _database.batch();

    for (final map in rows) {
      batch.insert(table, map, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }
}
