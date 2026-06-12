import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/constants/internal_constants/log.dart';
import '../../../../core/presentation/providers/core_providers.dart';
import '../../data/repositories/note_ai_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_controllers.dart';
import '../../domain/entities/selectable_note.dart';
import 'current_note_controller/current_note_controller.dart';
import 'current_note_controller/current_note_state.dart';
import 'editor_controller/editor_controller.dart';
import 'editor_controller/editor_state.dart';
import 'note_ai_controller/note_ai_controller.dart';
import 'note_ai_controller/note_ai_state.dart';
import 'note_controller/note_controller.dart';
import 'note_controller/sync_notes_controller.dart';

final noteControllerProvider =
    StreamNotifierProvider<NoteController, List<Note>>(() {
      return NoteController();
    });

final noteAiRepositoryProvider = Provider((ref) {
  final aiClient = ref.read(aiCilientProvider);
  final userRemoteDataSource = ref.read(userRemoteDataSourceProvider);
  return NoteAiRepositoryImpl(aiClient, userRemoteDataSource);
});

final noteAiNotiferProvider = NotifierProvider<NoteAiController, NoteAiState>(
  () {
    return NoteAiController();
  },
);

final currentNoteControllerProvider =
    NotifierProvider<CurrentNoteController, CurrentNoteState>(() {
      return CurrentNoteController();
    });

final isInNotesListScreen = StateProvider.autoDispose((_) => false);

final singleNoteStreamProvider = StreamProvider.family
    .autoDispose<Note?, String>((ref, noteId) {
      final controller = ref.read(noteControllerProvider.notifier);
      final stream = controller.fetchSingleNoteRealtime(noteId);

      final subscription = stream.listen((note) {
        if (note != null) {
          ref.read(currentNoteControllerProvider.notifier).replaceNote(note);
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

final syncNotesControllerProvider = NotifierProvider<SyncNotesController, bool>(
  () {
    return SyncNotesController();
  },
);

final selectableNoteProvider = StateProvider.autoDispose(
  (_) => SelectableNote(),
);

final getCreditsProvider = FutureProvider((ref) async {
  final userRepo = ref.read(userRepositoryProvider);
  final credits = await userRepo.getCredits();
  return credits;
});

final editorControllerProvider =
    NotifierProvider.autoDispose<EditorController, EditorState>(
      EditorController.new,
    );

final noteFormProvider = Provider.autoDispose((ref) {
  Logger.log(message: 'run noteFormProvider Provider');
  final formControllers = NoteFormControllers(
    title: TextEditingController(),
    content: TextEditingController(),
    formKey: GlobalKey(),
  );

  ref.onDispose(formControllers.dispose);

  return formControllers;
});
