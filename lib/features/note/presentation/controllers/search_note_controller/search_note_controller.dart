import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/features/note/injection.dart';
import 'package:link_note/features/note/presentation/controllers/search_note_controller/search_note_state.dart';

class SearchNoteController extends Notifier<SearchNoteState> {
  @override
  SearchNoteState build() {
    return const SearchNoteState();
  }

  void enableSearchMode() {
    state = state.copyWith(isSearchMode: true);
  }

  Future<void> search(String query) async {
    try {
      state = state.copyWith(isSearchingLoading: true);

      final results = await ref
          .read(notesRepositoryProvider)
          .searchNotes(query);

      state = state.copyWith(filteredNotes: results);
    } finally {
      state = state.copyWith(isSearchingLoading: false);
    }
  }
}
