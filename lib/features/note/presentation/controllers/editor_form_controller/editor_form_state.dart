// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../../domain/entities/note.dart';

class EditorFormState {
  EditorFormState({this.note, this.hasChanges = false});

  Note? note;
  bool hasChanges;

  EditorFormState copyWith({
    Note? note,
    bool? hasChanges,
  }) {
    return EditorFormState(
      note: note ?? this.note,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }
}
