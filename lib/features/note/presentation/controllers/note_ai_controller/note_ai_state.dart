import '../../../domain/entities/ai_response.dart';

class NoteAiState {
  NoteAiState({this.isContentProcessing = false,this.isTitleProcessing= false, this.noteContent,this.noteTitle});
  final bool isTitleProcessing;
  final bool isContentProcessing;
  final AiResponseEntity? noteContent;
  final AiResponseEntity? noteTitle;

  


  NoteAiState copyWith({
    bool? isTitleProcessing,
    bool? isContentProcessing,
    AiResponseEntity? noteContent,
    AiResponseEntity? noteTitle,
  }) {
    return NoteAiState(
      isTitleProcessing: isTitleProcessing ?? this.isTitleProcessing,
      isContentProcessing: isContentProcessing ?? this.isContentProcessing,
      noteContent: noteContent ?? this.noteContent,
      noteTitle: noteTitle ?? this.noteTitle,
    );
  }
}
