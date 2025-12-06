import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:link_note/features/auth/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'database/local/cache_service.dart';
import 'database/remote/database_service.dart';
import 'database/remote/storage_service.dart';
import 'network/network_service.dart';

Future<void> setupCommonDependincies() async {
  final prefs = await SharedPreferences.getInstance();

  getIt.registerLazySingleton<LocalCacheService>(
    () => LocalCacheServiceImpl(prefs),
  );

  getIt.registerLazySingleton<LocalCacheService>(
    () => LocalCacheServiceImpl(getIt()),
  );

  getIt.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );


  getIt.registerLazySingleton<RemoteDatabaseService>(
    () => RemoteDatabaseServiceImpl(getIt()),
  );


  getIt.registerLazySingleton<SupabaseStorageClient>(
    () => Supabase.instance.client.storage,
  );



  getIt.registerLazySingleton<RemoteStorageService>(
    () => RemoteStorageServiceImpl(getIt()),
  );

  getIt.registerLazySingleton<RemoteStorageService>(
    () => RemoteStorageServiceImpl(getIt()),
  );

  getIt.registerLazySingleton<NetworkService>(
    () => NetworkServiceImpl(InternetConnection.createInstance()),
  );


}
