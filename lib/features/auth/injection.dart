import 'package:get_it/get_it.dart';

import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/controllers/auth_controller.dart';

final getIt = GetIt.I;

void setupAuthDependincies() {
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt(),),
  );
 
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt(), getIt(),getIt()),
  );
 
  getIt.registerLazySingleton<AuthController>(
    () => AuthController(getIt()),
  );
}
