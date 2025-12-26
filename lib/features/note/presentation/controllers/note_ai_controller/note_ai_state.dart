import '../../../domain/entities/ai_response.dart';

class NoteAiState {
  NoteAiState({this.isLoading = false, this.result});
  final bool isLoading;
  final AiResponseEntity? result;

  NoteAiState copyWith({bool? isLoading, AiResponseEntity? result}) {
    return NoteAiState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
    );
  }
}
