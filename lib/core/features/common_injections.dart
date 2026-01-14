import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/injection.dart';
import '../constants/external_constants/external_constants.dart';
import 'database/local/cache_service.dart';
import 'database/local/local_database_service.dart';
import 'database/remote/remote_database_service.dart';
import 'database/remote/remote_storage_service.dart';
import 'network/connectivity_service.dart';
import 'network/network_clinet.dart';

Future<void> setupCommonDependincies() async {
  final prefs = await SharedPreferences.getInstance();
  final supabase = Supabase.instance;
  final database = await _initDatabase();

  getIt.registerLazySingleton<LocalCacheService>(
    () => LocalCacheServiceImpl(prefs),
  );

  getIt.registerLazySingleton<SupabaseClient>(() => supabase.client);

  getIt.registerLazySingleton<GoTrueClient>(() => supabase.client.auth);

  getIt.registerLazySingleton<Database>(() => database);

  getIt.registerLazySingleton<LocalDatabaseService>(
    () => LocalDatabaseServiceImpl(getIt()),
  );

  getIt.registerLazySingleton<RemoteDatabaseService>(
    () => RemoteDatabaseServiceImpl(getIt()),
  );

  getIt.registerLazySingleton<SupabaseStorageClient>(
    () => supabase.client.storage,
  );

  getIt.registerLazySingleton<RemoteStorageService>(
    () => RemoteStorageServiceImpl(getIt()),
  );

  getIt.registerLazySingleton<ConnectivityService>(
    () => ConnectivityServiceImpl(InternetConnection.createInstance()),
  );

  getIt.registerLazySingleton<http.Client>(http.Client.new);

  getIt.registerLazySingleton<NetworkClient>(() => NetworkClientImpl(getIt()));
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
