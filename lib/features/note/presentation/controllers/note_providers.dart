import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../../../../core/presentation/providers/core_providers.dart';
import '../../data/repositories/note_ai_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/selectable_note.dart';
import '../../injection.dart';
import 'note_ai_controller/note_ai_controller.dart';
import 'note_ai_controller/note_ai_state.dart';
import 'note_controller/note_controller.dart';
import 'note_controller/note_form_state.dart';

final noteControllerProvider = Provider((ref) {
  final noteRepo = ref.read(notesRepositoryProvider);
  final userRepo = ref.read(userRepositoryProvider);
  return NoteController(noteRepo, userRepo);
});

final noteAiRepositoryProvider = Provider((ref) {
  final aiClient = ref.read(aiCilientProvider);
  final userRemoteDataSource = ref.read(userRemoteDataSourceProvider);
  return NoteAiRepositoryImpl(aiClient, userRemoteDataSource);
});

final noteAiNotiferProvider =
    StateNotifierProvider<NoteAiController, NoteAiState>((ref) {
      final controller = ref.read(noteAiControllerProvider);
      return controller;
    });

final editorFormProvider = StateProvider((ref) {
  final state = EditorFormState();

  ref.onDispose(state.dispose);

  return state;
});

final isInNotesListScreen = StateProvider((_) => false);

final notesStreamProvider = StreamProvider.autoDispose((ref) {
  final notesController = ref.read(noteControllerProvider);

  return notesController.fetchNotesRealtime();
});

final singleNoteStreamProvider = StreamProvider.family
    .autoDispose<Note?, String>((ref, noteId) {
      final controller = ref.read(noteControllerProvider);
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
  final controller = ref.read(noteControllerProvider);
  return controller.getNoteById(noteId);
});

final syncNotesProvider = Provider((ref) {
  final network = ref.read(networkProvider);
  final controller = ref.read(noteControllerProvider);
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

final getCreditsProvider = FutureProvider((ref) async {
  ref.keepAlive();
  final userDataSource = ref.read(userRemoteDataSourceProvider);
  final result = await userDataSource.readCredits();
  if (result.value == null) return 0;
  return result.value!;
});
