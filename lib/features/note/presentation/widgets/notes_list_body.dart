import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/core/constants/internal_constants/log.dart';
import 'package:link_note/core/presentation/widgets/conditional_builder.dart';
import 'package:link_note/features/note/domain/entities/note.dart';
import 'package:link_note/features/note/presentation/controllers/note_providers.dart';
import 'notes_widget.dart';
import 'nothing_note.dart';

class NotesListBody extends ConsumerWidget {
  const NotesListBody({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isSearchMode = ref.watch(
      searchNoteControllerProvider.select((s) => s.isSearchMode),
    );

    final searchQuery = ref.watch(
      searchNoteControllerProvider.select((s) => s.searchQuery),
    );

    return ConditionalBuilder(
      condition: isSearchMode && searchQuery.isNotEmpty,
      builder: (_) => const _NotesSearchResults(key: ValueKey(true)),
      fallback: (_) => const _NotesStreamBuilder(key: ValueKey(false)),
    );
  }
}

class _NotesStreamBuilder extends ConsumerWidget {
  const _NotesStreamBuilder({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final notesAsync = ref.watch(noteControllerProvider);

    return notesAsync.when(
      skipLoadingOnReload: false,
      data: (notes) {
        if (notes.isEmpty) return const NothingNoteWidget();
        return NotesListView(notes: notes);
      },
      loading: () {
        final fakeNotes = List.generate(12, (index) => Note.fake());
        return NotesListView(notes: fakeNotes, isShimmerLoading: true);
      },

      error: (error, stackTrace) {
        Logger.log(error: error, stackTrace: stackTrace);
        return const Center(child: Text('حدث خطأ ما'));
      },
    );
  }
}

class _NotesSearchResults extends ConsumerWidget {
  const _NotesSearchResults({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final state = ref.watch(searchNoteControllerProvider);
    final isLoading = state.isSearchingLoading;
    final filteredNotes = state.filteredNotes;
    if (isLoading) {
      final fakeNotes = List.generate(8, (index) => Note.fake());

      return NotesListView(notes: fakeNotes);
    }

    return ConditionalBuilder(
      condition: filteredNotes.isNotEmpty,
      builder: (_) => NotesListView(notes: filteredNotes),
      fallback: (_) => const NotesSearchResultEmpty(),
    );
  }
}
