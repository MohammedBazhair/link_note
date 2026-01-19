import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/features/ai/ai_client.dart';
import '../../core/features/common_injections.dart';
import '../../core/presentation/providers/core_providers.dart';
import 'data/datasources/notes_local_data_source.dart';
import 'data/datasources/notes_remote_data_source.dart';
import 'data/repositories/note_ai_repository_impl.dart';
import 'data/repositories/notes_repository_impl.dart';
import 'domain/repositories/note_ai_repository.dart';
import 'domain/repositories/notes_repository.dart';
import 'presentation/controllers/note_ai_controller/note_ai_controller.dart';
import 'presentation/controllers/note_controller/note_controller.dart';

final notesRemoteDataSourceProvider = Provider((ref) {
  final remoteDatabaseService = ref.read(
    remoteDatabaseServiceProvider,
  ); // لاحظ استخدام watch
  return NotesRemoteDataSourceImpl(remoteDatabaseService);
});

final notesLocalDataSourceProvider = Provider<NotesLocalDataSource>((ref) {
  final localCacheService = ref.read(localCacheServiceProvider);
  final localDatabase = ref
      .read(localDatabaseProvider)
      .maybeWhen(
        data: (data) => data,
        orElse: () => throw Exception('localDatabase is null'),
      );

  return NotesLocalDataSourceImpl(localDatabase, localCacheService);
});

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final localDataSource = ref.read(notesLocalDataSourceProvider);
  final remote = ref.read(notesRemoteDataSourceProvider);
  final network = ref.read(networkProvider);
  final localCacheService = ref.read(localCacheServiceProvider);
  return NotesRepositoryImpl(
    remote,
    localDataSource,
    network,
    localCacheService,
  );
});

final noteAiRepositoryProvider = Provider<NoteAiRepository>((ref) {
  final aiClient = ref.read(aiCilientProvider);
  final userRemote = ref.watch(userRemoteDataSourceProvider);

  return NoteAiRepositoryImpl(aiClient, userRemote);
});

final noteControllerProvider = Provider<NoteController>((ref) {
  final notesRepo = ref.read(notesRepositoryProvider);
  final userRepo = ref.read(userRepositoryProvider);
  return NoteController(notesRepo, userRepo);
});


final noteAiControllerProvider = Provider<NoteAiController>((ref) {
  final aiRepo = ref.read(noteAiRepositoryProvider);
  return NoteAiController(aiRepo);
});

final aiClientProvider = Provider<AiClient>((ref) {
  final networkClint = ref.read(networkCilientProvider);

  return AiClientImpl(networkClint);
});

