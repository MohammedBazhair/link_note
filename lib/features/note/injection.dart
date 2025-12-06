import 'package:link_note/features/auth/injection.dart';

import 'data/datasources/notes_remote_data_source.dart';
import 'data/repositories/notes_repository_impl.dart';
import 'domain/repositories/notes_repository.dart';
import 'presentation/controllers/note_controller.dart';

void setupNotesDependincies() {
  getIt.registerLazySingleton<NotesRemoteDataSource>(
    () => NotesRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<NotesRepository>(
    () => NotesRepositoryImpl(getIt(), getIt(), getIt()),
  );

  getIt.registerLazySingleton<NoteController>(
    () => NoteController(getIt()),
  );
}
