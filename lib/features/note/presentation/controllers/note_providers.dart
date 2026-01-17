import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../../../../core/presentation/providers/core_providers.dart';
import '../../../user/domain/repositories/user_repository.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/selectable_note.dart';
import '../../domain/repositories/notes_repository.dart';
import 'note_ai_controller/note_ai_controller.dart';
import 'note_ai_controller/note_ai_state.dart';
import 'note_controller/note_controller.dart';
import 'note_controller/note_form_state.dart';

final noteControllerProvider = NotifierProvider<NoteController, void>(() {
  return GetIt.I<NoteController>();
});

final noteAiProvider =
    StateNotifierProvider.autoDispose<NoteAiController, NoteAiState>((ref) {
      return GetIt.I<NoteAiController>();
    });

final notesRepositoryProvider = Provider((_) {
  return GetIt.I<NotesRepository>();
});

final userRepositoryProvider = Provider((_) {
  return GetIt.I<UserRepository>();
});

final editorFormProvider = StateProvider((ref) {
  final state = EditorFormState();

  ref.onDispose(state.dispose);

  return state;
});

final isInNotesListScreen = StateProvider((_) => false);

final notesStreamProvider = StreamProvider.autoDispose((ref) {
  final notesController = ref.read(noteControllerProvider.notifier);

  return notesController.fetchNotesRealtime();
});

final singleNoteStreamProvider = StreamProvider.family
    .autoDispose<Note?, String>((ref, noteId) {
      final controller = ref.read(noteControllerProvider.notifier);
      final stream = controller.fetchSingleNoteRealtime(noteId);

      final subscription = stream.listen((note) {
        if (note != null) {
          ref.read(editorFormProvider).syncWith(note);
        }
      });

      ref.onDispose(subscription.cancel);

      return stream;
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

final selectableNoteProvider = StateProvider.autoDispose(
  (_) => SelectableNote(),
);
