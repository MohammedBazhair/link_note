import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:link_note/features/note/presentation/controllers/notes_contextual_action_bar_controller/notes_contextual_action_bar_controller.dart';
import 'package:link_note/features/note/presentation/controllers/search_note_controller/search_note_controller.dart';
import '../../../../core/presentation/providers/core_providers.dart';
import '../../data/repositories/note_ai_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_controllers.dart';
import '../../domain/entities/selectable_note.dart';
import 'current_note_controller/current_note_controller.dart';
import 'editor_controller/editor_controller.dart';
import 'note_ai_controller/note_ai_controller.dart';
import 'note_controller/note_controller.dart';
import 'note_controller/sync_notes_controller.dart';

final noteControllerProvider = StreamNotifierProvider(NoteController.new);

final noteAiRepositoryProvider = Provider((ref) {
  final aiClient = ref.read(aiCilientProvider);
  final userRemoteDataSource = ref.read(userRemoteDataSourceProvider);
  final connectivityService = ref.read(networkProvider);
  return NoteAiRepositoryImpl(
    aiClient,
    userRemoteDataSource,
    connectivityService,
  );
});

final noteAiNotiferProvider = NotifierProvider(NoteAiController.new);

final currentNoteControllerProvider = NotifierProvider(
  CurrentNoteController.new,
);

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

final editorControllerProvider = NotifierProvider.autoDispose(
  EditorController.new,
);

final noteFormProvider = StateProvider.autoDispose((ref) {
  final formControllers = NoteFormControllers(
    title: TextEditingController(),
    content: TextEditingController(),
    formKey: GlobalKey(),
  );

  ref.onDispose(formControllers.dispose);

  return formControllers;
});

final notesContextualActionBarController = NotifierProvider(
  NotesContextualActionBarController.new,
);

final searchNoteControllerProvider = NotifierProvider(SearchNoteController.new);
