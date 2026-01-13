import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get_it/get_it.dart';

import '../../../session/presentation/controllers/session_controller.dart';
import '../../../user/domain/repositories/user_repository.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';

final notesRepositoryProvider = Provider((_) {
  return GetIt.I<NotesRepository>();
});

final userRepositoryProvider = Provider((_) {
  return GetIt.I<UserRepository>();
});

final isInNotesListScreen = StateProvider((_) => false);

final notesStreamProvider = StreamProvider.autoDispose((ref) {
  final notesRepo = ref.watch(notesRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);

  final userId = userRepo.currentUser?.id;

  return notesRepo.fetchNotesRealTime(userId).map((notes) {
    final sorted = List<Note>.from(notes);
    sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  });
});

final singleNoteStreamProvider = StreamProvider.family
    .autoDispose<Note?, String>((ref, noteId) {
      ref.onDispose(() {
        print('Disposed singleNoteStreamProvider for noteId: $noteId');
      });
      final repo = ref.watch(notesRepositoryProvider);
      return repo.fetchNoteStream(noteId);
    });

final getNoteByIdProvider = FutureProvider.family.autoDispose<Note?, String>((
  ref,
  noteId,
) {
  final repo = ref.watch(notesRepositoryProvider);
  return repo.getNoteById(noteId);
});

final sessionMembersStreamProvider = StreamProvider.autoDispose((ref) {
  final sessionController = ref.read(sessionControllerProvider.notifier);

  return sessionController.fetchMembersOfSession();
});
