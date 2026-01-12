import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get_it/get_it.dart';

import '../../../user/domain/repositories/user_repository.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';

final notesRepositoryProvider = Provider((_){
  return GetIt.I<NotesRepository>();
});

final userRepositoryProvider = Provider((_){
  return GetIt.I<UserRepository>();
});


final isInNotesListScreen = StateProvider((_) => false);

final notesStreamProvider = StreamProvider.autoDispose((ref) {
  final notesRepo = ref.watch(notesRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);

  final userId = userRepo.currentUser?.id;

  return notesRepo.fetchNotesRealTime(userId);
});


final singleNoteStreamProvider = StreamProvider.family
    .autoDispose<Note?, String>((ref, noteId) {
      final repo = ref.watch(notesRepositoryProvider);
      return repo.fetchNoteStream(noteId);
    });

final getNoteByIdProvider = FutureProvider.family
    .autoDispose<Note?, String>((ref, noteId) {
      final repo = ref.watch(notesRepositoryProvider);
      return  repo.getNoteById(noteId);
    });
