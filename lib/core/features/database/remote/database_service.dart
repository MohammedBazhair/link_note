import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class RemoteDatabaseService {
  Future<Map<String, dynamic>> insertRow({
    required Map<String, dynamic> map,
    required String table,
  });

  Future<Map<String, dynamic>> readRow({
    required String id,
    required String column,
    required String table,
  });

  Future<List<Map<String, dynamic>>> readRowsWhere({
    required String table,
    required Map<String, Object> filters,
  });

  Future<List<Map<String, dynamic>>> readRows({required String table});

  Stream readRowsRealTime({
    required String table,
    required List<String> primaryKey,
  });

  Future<dynamic> update({
    required Map<String, dynamic> updated,
    required String id,
    required String column,
    required String table,
  });

  Future<void> delete({
    required String id,
    required String column,
    required String table,
  });

  Future<void> deleteWhere({
    required String table,
    required Map<String, Object> filters,
  });
}

class RemoteDatabaseServiceImpl implements RemoteDatabaseService {
  RemoteDatabaseServiceImpl(this._client);
  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>> insertRow({
    required Map<String, dynamic> map,
    required String table,
  }) {
    return _client.from(table).insert(map).select().single();
  }

  @override
  Future<Map<String, dynamic>> readRow({
    required String id,
    required String column,
    required String table,
  }) {
    return _client.from(table).select().eq(column, id).single();
  }

  @override
  Future<List<Map<String, dynamic>>> readRows({required String table}) {
    return _client.from(table).select();
  }

  @override
  Future<dynamic> update({
    required Map<String, dynamic> updated,
    required String id,
    required String column,
    required String table,
  }) {
    return _client.from(table).update(updated).eq(column, id);
  }

  @override
  Future<void> delete({
    required String id,
    required String column,
    required String table,
  }) {
    return _client.from(table).delete().eq(column, id);
  }

  @override
  Stream readRowsRealTime({
    required String table,
    required List<String> primaryKey,
  }) {
    return _client.from(table).stream(primaryKey: primaryKey);
  }

  @override
  Future<void> deleteWhere({
    required String table,
    required Map<String, Object> filters,
  }) async {
    await _client.from(table).delete().match(filters);
  }

  @override
  Future<List<Map<String, dynamic>>>  readRowsWhere({
    required String table,
    required Map<String, Object> filters,
  }) {
    return _client.from(table).select().match(filters);
  }
}
