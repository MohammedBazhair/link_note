import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/core/utils/debouncer.dart';
import 'package:link_note/features/note/injection.dart';
import 'package:link_note/features/note/presentation/controllers/search_note_controller/search_note_state.dart';

class SearchNoteController extends Notifier<SearchNoteState> {
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  SearchNoteState build() {
    ref.onDispose(_debouncer.dispose);

    return const SearchNoteState();
  }

  void enableSearchMode() {
    state = state.copyWith(isSearchMode: true);
  }

  void closeSearchMode() {
    _debouncer.dispose();
    state = const SearchNoteState();
  }

  void search(String query) {
    if (query.trim().isEmpty) {
      state = state.copyWith(filteredNotes: [], isSearchingLoading: false);
      return;
    }

    state = state.copyWith(isSearchingLoading: true,searchQuery: query);

    _debouncer.run(() => _debounceSearch(query));
  }

  void _debounceSearch(String query) async {
    try {
      final results = await ref
          .read(notesRepositoryProvider)
          .searchNotes(query);

      if (!ref.mounted) return;
      state = state.copyWith(filteredNotes: results);
    } finally {
      if (ref.mounted) {
        state = state.copyWith(isSearchingLoading: false);
      }
    }
  }
}
