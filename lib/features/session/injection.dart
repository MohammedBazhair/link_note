import '../auth/injection.dart';
import 'data/repository/session_repository_impl.dart';
import 'domain/repository/session_repository.dart';
import 'presentation/controllers/session_controller.dart';

void setupSessionsDependincies() {
  getIt.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton<SessionController>(
    () => SessionController(getIt()),
  );
}
