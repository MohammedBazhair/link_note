import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../constants/external_constants/external_constants.dart';
import '../constants/internal_constants/log.dart';
import 'database/local/local_database_service.dart';

final localDatabaseProvider = Provider<LocalDatabaseServiceImpl>((ref) {
  throw Exception('');
});

Future<Override> getOverrideDatabase() async {
  final db = await _initDatabase();
  final value = LocalDatabaseServiceImpl(db);
  return localDatabaseProvider.overrideWithValue(value);
}

Future<Database> _initDatabase() async {
  final dbPath = await getDatabaseFilePath();
  Logger.log(message: 'Database path: $dbPath');
  
  if (Platform.isWindows) {
    final winDb = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(version: 1, onCreate: _onCreate),
    );
    return winDb;
  }

  final androidDb = await openDatabase(dbPath, version: 1, onCreate: _onCreate);

  return androidDb;
}

Future<String> getDatabaseFilePath() async {
  try {
    final dbPath = await getExternalStorageDirectory();
    if (dbPath == null) throw Exception();
    return join(dbPath.path, ExternalConsts.databaseName);
  } catch (e) {
    final dbPath = await getDatabasesPath();
    return join(dbPath, ExternalConsts.databaseName);
  }
}

Future<void> _onCreate(Database db, int version) async {
  final futures = [
    db.execute(ExternalConsts.createTableNotesQuery),
    db.execute(ExternalConsts.createTableSyncChangesQuery),
    db.execute(ExternalConsts.createTableSyncStateQuery),
  ];

  await Future.wait(futures);
}
