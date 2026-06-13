import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/features/note/injection.dart';
import 'package:link_note/features/note/presentation/controllers/search_note_controller/search_note_state.dart';

class SearchNoteController extends Notifier<SearchNoteState> {
  Timer? _timer;
  @override
  SearchNoteState build() {
    ref.onDispose(() => _timer?.cancel());

    return const SearchNoteState();
  }

  void enableSearchMode() {
    state = state.copyWith(isSearchMode: true);
  }

  void closeSearchMode() {
    _timer?.cancel();
    state = const SearchNoteState();
  }

  void search(String query) {
    _timer?.cancel();

    if (query.trim().isEmpty) {
      state = state.copyWith(filteredNotes: [], isSearchingLoading: false);
      return;
    }

    state = state.copyWith(isSearchingLoading: true);

    _timer = Timer(const Duration(milliseconds: 400), () async {
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
    });
  }
}
