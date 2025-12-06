import 'package:get_it/get_it.dart';
import 'package:link_note/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:link_note/features/auth/presentation/controllers/auth_controller.dart';

import 'data/datasources/auth_remote_data_source.dart';
import 'domain/repositories/auth_repository.dart';

final getIt = GetIt.I;

void setupAuthDependincies() {
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );
 
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt(), getIt()),
  );
 
  getIt.registerLazySingleton<AuthController>(
    () => AuthController(getIt()),
  );
}
