import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../../features/user/data/datasources/user_local_data_source.dart';
import '../../../features/user/data/datasources/user_remote_data_source.dart';
import '../../../features/user/data/repositories/user_repository_impl.dart';
import '../../../features/user/presentation/controllers/user_controller.dart';
import '../../../features/user/presentation/controllers/user_state.dart';
import '../../features/ai/ai_client.dart';
import '../../features/database/local/secure_cache_service_impl.dart';
import '../../features/database/remote/remote_database_service.dart';
import '../../features/database/remote/remote_storage_service.dart';
import '../../features/init_local_data_base.dart';
import '../../features/memory_cache/memory_cache.dart';
import '../../features/network/connectivity_service.dart';
import '../../features/network/network_clinet.dart';
import '../../features/sync/sync_local_data_source.dart';
import '../controllers/selection_controller.dart';

final networkProvider = Provider((_) {
  final _connection = InternetConnection();
  return ConnectivityServiceImpl(_connection);
});

final supabaseProvider = Provider((ref) {
  return Supabase.instance;
});

final supabaseAuthProvider = Provider((ref) {
  final auth = ref.read(supabaseProvider).client.auth;
  return auth;
});

final httpClinetProvider = Provider((ref) {
  return http.Client();
});

final networkCilientProvider = Provider((ref) {
  final clinet = ref.read(httpClinetProvider);

  return NetworkClientImpl(clinet);
});

final aiCilientProvider = Provider((ref) {
  final functionsClient = ref.read(supabaseProvider).client.functions;

  return AiClientImpl(functionsClient);
});

final authRemoteDataSourceProvider = Provider((ref) {
  final auth = ref.read(supabaseAuthProvider);
  final userRemote = ref.read(userRemoteDataSourceProvider);
  return AuthRemoteDataSourceImpl(auth, userRemote);
});

final userLocalDataSourceProvider = Provider((ref) {
  final localCache = ref.read(secureCacheServiceProvider);
  return UserLocalDataSourceImpl(localCache);
});

final userRepositoryProvider = Provider((ref) {
  final auth = ref.read(supabaseAuthProvider);
  final userRemoteDataSource = ref.read(userRemoteDataSourceProvider);
  final userLocalDataSource = ref.read(userLocalDataSourceProvider);

  return UserRepositoryImpl(userRemoteDataSource, userLocalDataSource, auth);
});

final remoteDatabaseServiceProvider = Provider((ref) {
  final supabaseClinet = ref.read(supabaseProvider).client;
  return RemoteDatabaseServiceImpl(supabaseClinet);
});

final remoteStorageServiceProvider = Provider((ref) {
  final supabaseStorage = ref.read(supabaseProvider).client.storage;
  return RemoteStorageServiceImpl(supabaseStorage);
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  const storage = FlutterSecureStorage();
  return storage;
});

final secureCacheServiceProvider = Provider((ref) {
  final secure = ref.read(secureStorageProvider);
  return SecureCacheServiceImpl(secure);
});

final userRemoteDataSourceProvider = Provider((ref) {
  final supabaseClinet = ref.read(supabaseProvider).client;
  final remoteDatabaseService = ref.read(remoteDatabaseServiceProvider);
  final remoteStorageService = ref.read(remoteStorageServiceProvider);
  final localCacheService = ref.read(secureCacheServiceProvider);
  return UserRemoteDataSourceImpl(
    supabaseClinet,
    remoteDatabaseService,
    remoteStorageService,
    localCacheService,
  );
});

final _userControllerProvider = Provider((ref) {
  final repo = ref.read(userRepositoryProvider);
  return UserController(repo);
});

final userControllerProvider = StateNotifierProvider<UserController, UserState>(
  (ref) {
    final controller = ref.read(_userControllerProvider);
    return controller;
  },
);

final authRepositoryProvider = Provider((ref) {
  final remoteAuth = ref.read(authRemoteDataSourceProvider);
  final network = ref.read(networkProvider);
  final _cache = ref.read(secureCacheServiceProvider);
  return AuthRepositoryImpl(remoteAuth, network, _cache);
});

Future<List<Override>> getOverrides() async {
  final dbOverride = await getOverrideDatabase();
  return [dbOverride];
}

final memoryCacheProvider = Provider((ref) => MemoryCache());

final syncLocalProvider = Provider((ref) {
  final localCache = ref.read(localDatabaseProvider);
  return SyncLocalDataSourceImpl(localCache);
});

final selectionControllerProvider =
    NotifierProvider<SelectionController, Set<String>>(SelectionController.new);
