import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/features/note/presentation/controllers/note_providers.dart';

import 'notes_contextual_action_bar_state.dart';

class NotesContextualActionBarController
    extends Notifier<NotesContextualActionBarState> {
  @override
  NotesContextualActionBarState build() {
    return const NotesContextualActionBarState();
  }

  void closeActionBar() {
    state = state.copyWith(actionBarOpened: false);
  }

  void toggleNote(String noteId) {
    final copiedSelected = {...state.selectedNotesIds};

    if (copiedSelected.contains(noteId)) {
      copiedSelected.remove(noteId);
    } else {
      copiedSelected.add(noteId);
    }

    state = state.copyWith(
      selectedNotesIds: copiedSelected,
      actionBarOpened: copiedSelected.isNotEmpty,
    );
  }

  void deleteSelectedNotes() {
    final ids = state.selectedNotesIds;
    ref.read(noteControllerProvider.notifier).deleteNotes(ids);
  }
}
