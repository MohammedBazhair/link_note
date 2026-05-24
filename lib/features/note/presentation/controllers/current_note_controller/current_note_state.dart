// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../../domain/entities/note.dart';

enum CurrentNoteFunctionality{
  add,
  edit
}

class CurrentNoteState {
  CurrentNoteState({ this.note, this.currentNoteFunctionality= CurrentNoteFunctionality.add});

  final Note? note;
  final CurrentNoteFunctionality currentNoteFunctionality;


  CurrentNoteState copyWith({
    Note? note,
    CurrentNoteFunctionality? currentNoteFunctionality,
  }) {
    return CurrentNoteState(
      note: note ?? this.note,
      currentNoteFunctionality: currentNoteFunctionality ?? this.currentNoteFunctionality,
    );
  }
}
