// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../../domain/entities/note.dart';

enum CurrentNoteFunctionality { add, edit }

enum CurrentNoteAction { delete }

class CurrentNoteState {
  CurrentNoteState({
    this.note,
    this.currentNoteFunctionality = CurrentNoteFunctionality.add,
    this.currentNoteAction,
    this.error,
    this.successMessage,
  });

  final Note? note;
  final CurrentNoteFunctionality currentNoteFunctionality;
  final CurrentNoteAction? currentNoteAction;
  final String? error;
  final String? successMessage;

  CurrentNoteState copyWith({
    Note? note,
    CurrentNoteFunctionality? currentNoteFunctionality,
    CurrentNoteAction? currentNoteAction,
    String? error,
    String? successMessage,
  }) {
    return CurrentNoteState(
      note: note ?? this.note,
      currentNoteFunctionality:
          currentNoteFunctionality ?? this.currentNoteFunctionality,
      currentNoteAction: currentNoteAction,
      error: error ,
      successMessage: successMessage ,
    );
  }
}
