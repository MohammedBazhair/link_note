import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class RemoteDatabaseService {
  Future<dynamic> insertRow({
    required Map<String, dynamic> map,
    required String table,
  });

  Future<Map<String, dynamic>> readRow({
    required String id,
    required String column,
    required String table,
  });

  Future<List<Map<String, dynamic>>> readRows({required String table});

  Stream  readRowsRealTime({
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
}

class RemoteDatabaseServiceImpl implements RemoteDatabaseService {

  RemoteDatabaseServiceImpl(this._client);
  final SupabaseClient _client;

  @override
  Future<dynamic> insertRow({
    required Map<String, dynamic> map,
    required String table,
  }) {
    return _client.from(table).insert(map);
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
  Stream  readRowsRealTime({required String table, required List<String> primaryKey}) {
    return _client.from(table).stream(primaryKey: primaryKey);
  }
}
