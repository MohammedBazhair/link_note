import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/injection.dart';
import 'database/local/cache_service.dart';
import 'database/remote/database_service.dart';
import 'database/remote/storage_service.dart';
import 'network/network_service.dart';

Future<void> setupCommonDependincies() async {
  final prefs = await SharedPreferences.getInstance();
  final supabase = Supabase.instance;
  final googleSignIn = GoogleSignIn.instance;

  getIt.registerLazySingleton<LocalCacheService>(
    () => LocalCacheServiceImpl(prefs),
  );

  getIt.registerLazySingleton<SupabaseClient>(() => supabase.client);

  getIt.registerLazySingleton<GoTrueClient>(() => supabase.client.auth);
  
  getIt.registerLazySingleton<GoogleSignIn>(() => googleSignIn);

  getIt.registerLazySingleton<RemoteDatabaseService>(
    () => RemoteDatabaseServiceImpl(getIt()),
  );

  getIt.registerLazySingleton<SupabaseStorageClient>(
    () => supabase.client.storage,
  );

  getIt.registerLazySingleton<RemoteStorageService>(
    () => RemoteStorageServiceImpl(getIt()),
  );

  getIt.registerLazySingleton<NetworkService>(
    () => NetworkServiceImpl(InternetConnection.createInstance()),
  );
}
