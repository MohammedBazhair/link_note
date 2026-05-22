import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/features/ai/ai_client.dart';
import '../../core/features/init_local_data_base.dart';
import '../../core/presentation/providers/core_providers.dart';
import 'data/datasources/notes_local_data_source.dart';
import 'data/datasources/notes_remote_data_source.dart';
import 'data/repositories/note_ai_repository_impl.dart';
import 'data/repositories/notes_repository_impl.dart';
import 'data/repositories/sync_note_repository_impl.dart';
import 'domain/repositories/note_ai_repository.dart';
import 'domain/repositories/notes_repository.dart';
import 'domain/repositories/sync_note_repository.dart';
import 'presentation/controllers/note_ai_controller/note_ai_controller.dart';

final notesRemoteDataSourceProvider = Provider((ref) {
  final remoteDatabaseService = ref.read(remoteDatabaseServiceProvider);
  final _client = ref.read(supabaseProvider).client;
  return NotesRemoteDataSourceImpl(remoteDatabaseService, _client);
});

final notesLocalDataSourceProvider = Provider<NotesLocalDataSource>((ref) {
  final localDatabase = ref.read(localDatabaseProvider);
  final syncLocal = ref.read(syncLocalProvider);

  return NotesLocalDataSourceImpl(localDatabase, syncLocal);
});

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final localDataSource = ref.read(notesLocalDataSourceProvider);
  final remote = ref.read(notesRemoteDataSourceProvider);
  final network = ref.read(networkProvider);
  final _cache = ref.read(secureCacheServiceProvider);
  return NotesRepositoryImpl(
    remote,
    localDataSource,
    network,
    _cache,
  );
});

final syncNotesRepositoryProvider = Provider<SyncNoteRepository>((ref) {
  final _cache = ref.read(secureCacheServiceProvider);
  final _sync = ref.read(syncLocalProvider);
  final _connectivity = ref.read(networkProvider);
  final _localNotes = ref.read(notesLocalDataSourceProvider);
  final _remoteNotes = ref.read(notesRemoteDataSourceProvider);
  return SyncNoteRepositoryImpl(
    _cache,
    _sync,
    _connectivity,
    _localNotes,
    _remoteNotes,
  );
});

final noteAiRepositoryProvider = Provider<NoteAiRepository>((ref) {
  final aiClient = ref.read(aiCilientProvider);
  final userRemote = ref.watch(userRemoteDataSourceProvider);

  return NoteAiRepositoryImpl(aiClient, userRemote);
});

final noteAiControllerProvider = Provider<NoteAiController>((ref) {
  final aiRepo = ref.read(noteAiRepositoryProvider);
  return NoteAiController(aiRepo);
});

final aiClientProvider = Provider<AiClient>((ref) {
  final _client = ref.read(supabaseProvider).client.functions;

  return AiClientImpl(_client);
});
