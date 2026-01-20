import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../constants/external_constants/external_constants.dart';
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
  final dbDir = await getDatabasesPath();
  final dbPath = join(dbDir, 'LinkNote.db');
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

Future<void> _onCreate(Database db, int version) async {
  await db.execute(ExternalConsts.createTableNotesQuery);
}
