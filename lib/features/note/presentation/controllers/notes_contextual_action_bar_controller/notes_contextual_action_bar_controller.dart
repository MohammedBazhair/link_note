import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/core/constants/internal_constants/log.dart';
import 'package:link_note/features/note/presentation/controllers/note_providers.dart';
import 'notes_contextual_action_bar_state.dart';

class NotesContextualActionBarController
    extends Notifier<NotesContextualActionBarState> {
  @override
  NotesContextualActionBarState build() {
    return const NotesContextualActionBarState();
  }

  final _deletedNotesHistory = <String>{};

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

  Future<void> deleteSelectedNotes() async {
    final ids = state.selectedNotesIds;
    final length = ids.length;
    try {
      await ref.read(noteControllerProvider.notifier).deleteNotes(ids);

      state = state.copyWith(
        actionBarOpened: false,
        currentAction: NotesContextualAppBarAction.deleteNotes,
        selectedNotesIds: {},
        successMessage: 'تم حذف $length من الملاحظات',
      );

      _deletedNotesHistory.addAll(ids);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'حدثت مشكلة أثناء محاولة حذف $length من الملاحظات',
      );
    }
  }

  Future<void> undoDeleteNotes() async {
    if (_deletedNotesHistory.isEmpty) return;

    try {
      await ref
          .read(noteControllerProvider.notifier)
          .undoDeleteNotes(_deletedNotesHistory);

      _deletedNotesHistory.clear();
    } catch (e) {
      Logger.log(error: e);
    }
  }
}
