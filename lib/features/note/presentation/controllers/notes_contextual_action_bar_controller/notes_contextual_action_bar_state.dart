// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class NotesContextualActionBarState extends Equatable {
  const NotesContextualActionBarState({
    this.actionBarOpened = false,
    this.selectedNotesIds = const {},
  });

  final bool actionBarOpened;
  final Set<String> selectedNotesIds;

  @override
  List<Object?> get props => [actionBarOpened, selectedNotesIds];

  NotesContextualActionBarState copyWith({
    bool? actionBarOpened,
    Set<String>? selectedNotesIds,
  }) {
    return NotesContextualActionBarState(
      actionBarOpened: actionBarOpened ?? this.actionBarOpened,
      selectedNotesIds: selectedNotesIds ?? this.selectedNotesIds,
    );
  }
}
