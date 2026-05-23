import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/constants/internal_constants/log.dart';
import '../../../../core/presentation/providers/core_providers.dart';
import '../../../user/presentation/controllers/user_providers.dart';
import '../../data/repositories/note_ai_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_controllers.dart';
import '../../domain/entities/selectable_note.dart';
import 'editor_form_controller/editor_form_controller.dart';
import 'editor_history_controller/editor_history_controller.dart';
import 'editor_history_controller/editor_history_state.dart';
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

final editorFormControllerProvider =
    NotifierProvider<EditorFormController, Note?>(() {
      return EditorFormController();
    });

final isInNotesListScreen = StateProvider.autoDispose((_) => false);

final singleNoteStreamProvider = StreamProvider.family
    .autoDispose<Note?, String>((ref, noteId) {
      final controller = ref.read(noteControllerProvider.notifier);
      final stream = controller.fetchSingleNoteRealtime(noteId);

      final subscription = stream.listen((note) {
        if (note != null) {
          ref.read(editorFormControllerProvider.notifier).syncWith(note);
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
  final userDataSource = ref.read(userRemoteDataSourceProvider);
  final isUserLoggedIn = ref.read(isUserLoggedInProvider);
  if (!isUserLoggedIn) return 0;
  final result = await userDataSource.readCredits();
  if (result.value == null) return 0;
  return result.value!;
});

final editorHistoryControllerProvider =
    NotifierProvider.autoDispose<EditorHistoryController, EditorHistoryState>(
      EditorHistoryController.new,
    );

final noteFormProvider = Provider.autoDispose((ref) {
  Logger.log(message: 'run noteFormProvider Provider');
  final formControllers = NoteFormControllers(
    title: TextEditingController(),
    content: TextEditingController(),
    formKey: GlobalKey(),
  );

  final historyController = ref.read(editorHistoryControllerProvider.notifier);
  void sync() {
    Logger.log(message: 'addListener');
    historyController.edit(
      title: formControllers.title.text,
      content: formControllers.content.text,
    );
  }

  formControllers.title.addListener(sync);

  formControllers.content.addListener(sync);

  ref.onDispose(() => formControllers.dispose(sync));

  return formControllers;
});
