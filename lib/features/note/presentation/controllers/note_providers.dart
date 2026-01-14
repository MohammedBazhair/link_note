import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../../../../core/constants/internal_constants/log.dart';
import '../../../../core/presentation/providers/core_providers.dart';
import '../../../user/domain/repositories/user_repository.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import 'note_controller/note_controller.dart';

final notesRepositoryProvider = Provider((_) {
  return GetIt.I<NotesRepository>();
});

final userRepositoryProvider = Provider((_) {
  return GetIt.I<UserRepository>();
});

final isInNotesListScreen = StateProvider((_) => false);

final notesStreamProvider = StreamProvider.autoDispose((ref) {
  final notesController = ref.read(noteControllerProvider.notifier);

  return notesController.fetchNotesRealtime();
});

final singleNoteStreamProvider = StreamProvider.family
    .autoDispose<Note?, String>((ref, noteId) {
      ref.onDispose(() {
        Logger.log(
          message: 'Disposed singleNoteStreamProvider for noteId: $noteId',
        );
      });
      final controller = ref.read(noteControllerProvider.notifier);
      return controller.fetchSingleNoteRealtime(noteId);
    });

final getNoteByIdProvider = FutureProvider.family.autoDispose<Note?, String>((
  ref,
  noteId,
) {
  final controller = ref.read(noteControllerProvider.notifier);
  return controller.getNoteById(noteId);
});

final syncNotesProvider = Provider((ref) {
  final network = ref.read(networkProvider);
  final controller = ref.read(noteControllerProvider.notifier);
  // استمع لتغييرات الاتصال
  final subscription = network.listenToConnectionChanges((status) async {
    if (status == InternetStatus.connected) {
      await controller.syncNotes();
    }
  });

  ref.onDispose(subscription.cancel);
});
