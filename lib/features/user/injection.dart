import 'package:link_note/features/auth/injection.dart';
import 'package:link_note/features/user/presentation/controllers/user_controller.dart';

import 'data/datasources/user_remote_data_source.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/repositories/user_repository.dart';

void setupUserDependincies() {
  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(getIt(), getIt(), getIt()),
  );

  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton<UserController>(() => UserController(getIt()));
}
