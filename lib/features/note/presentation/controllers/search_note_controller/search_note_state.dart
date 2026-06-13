import 'package:equatable/equatable.dart';
import 'package:link_note/features/note/domain/entities/note.dart';

class SearchNoteState extends Equatable {
  const SearchNoteState({
    this.filteredNotes = const [],
    this.isSearchMode = false,
    this.isSearchingLoading = false,
  });

  final List<Note> filteredNotes;
  final bool isSearchMode;
  final bool isSearchingLoading;

  SearchNoteState copyWith({
    List<Note>? filteredNotes,
    bool? isSearchMode,
    bool? isSearchingLoading,
  }) {
    return SearchNoteState(
      filteredNotes: filteredNotes ?? this.filteredNotes,
      isSearchMode: isSearchMode ?? this.isSearchMode,
      isSearchingLoading: isSearchingLoading ?? this.isSearchingLoading,
    );
  }

  @override
  List<Object?> get props => [filteredNotes, isSearchMode, isSearchingLoading];
}
