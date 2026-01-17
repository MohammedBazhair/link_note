
class NoteAiState {
  NoteAiState({
    this.isContentProcessing = false,
    this.isTitleProcessing = false,
  });
  final bool isTitleProcessing;
  final bool isContentProcessing;

  NoteAiState copyWith({
    bool? isTitleProcessing,
    bool? isContentProcessing,
  }) {
    return NoteAiState(
      isTitleProcessing: isTitleProcessing ?? this.isTitleProcessing,
      isContentProcessing: isContentProcessing ?? this.isContentProcessing,
    );
  }
}
