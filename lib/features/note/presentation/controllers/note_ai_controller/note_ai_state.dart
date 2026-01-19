sealed class NoteAiState {
  NoteAiState({
    this.isContentProcessing = false,
    this.isTitleProcessing = false,
  });
  final bool isTitleProcessing;
  final bool isContentProcessing;
}

class ShowMessageAiNoteState extends NoteAiState {
  ShowMessageAiNoteState({
    super.isContentProcessing,
    super.isTitleProcessing,
    required this.message,
  });

  final String message;
}

class UpdatingAiNoteState extends NoteAiState {
  UpdatingAiNoteState({super.isContentProcessing, super.isTitleProcessing});
}

class ResetAiNoteState extends NoteAiState {
  ResetAiNoteState() : super();
}

class SuccessAiNoteState extends NoteAiState {
  SuccessAiNoteState() : super();
}
