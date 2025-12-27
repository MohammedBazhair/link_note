import '../../core/features/ai/ai_client.dart';
import '../auth/injection.dart';
import 'data/datasources/notes_local_data_source.dart';
import 'data/datasources/notes_remote_data_source.dart';
import 'data/repositories/note_ai_repository_impl.dart';
import 'data/repositories/notes_repository_impl.dart';
import 'domain/repositories/note_ai_repository.dart';
import 'domain/repositories/notes_repository.dart';
import 'presentation/controllers/note_ai_controller/note_ai_controller.dart';
import 'presentation/controllers/note_controller/note_controller.dart';

void setupNotesDependincies() {
  getIt.registerLazySingleton<NotesRemoteDataSource>(
    () => NotesRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<NotesLocalDataSource>(
    () => NotesLocalDataSourceImpl(getIt(), getIt()),
  );

  getIt.registerLazySingleton<NotesRepository>(
    () => NotesRepositoryImpl(getIt(), getIt(), getIt(), getIt()),
  );

  getIt.registerLazySingleton<NoteController>(
    () => NoteController(getIt(), getIt()),
  );

  getIt.registerLazySingleton<AiClient>(() => AiClientImpl(getIt()));


  getIt.registerLazySingleton<NoteAiRepository>(
    () => NoteAiRepositoryImpl(getIt()),
  );

  getIt.registerFactory<NoteAiController>(() => NoteAiController(getIt()));
}
