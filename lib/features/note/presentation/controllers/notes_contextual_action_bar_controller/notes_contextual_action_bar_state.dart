import 'package:equatable/equatable.dart';

enum NotesContextualAppBarAction { deleteNotes }

class NotesContextualActionBarState extends Equatable {
  const NotesContextualActionBarState({
    this.actionBarOpened = false,
    this.selectedNotesIds = const {},
    this.errorMessage,
    this.successMessage,
    this.currentAction,
  });

  final bool actionBarOpened;
  final Set<String> selectedNotesIds;
  final NotesContextualAppBarAction? currentAction;
  final String? errorMessage;
  final String? successMessage;

  @override
  List<Object?> get props => [
    actionBarOpened,
    selectedNotesIds,
    successMessage,
    errorMessage,
  ];

  NotesContextualActionBarState copyWith({
    bool? actionBarOpened,
    Set<String>? selectedNotesIds,
    String? errorMessage,
    String? successMessage,
    NotesContextualAppBarAction? currentAction
  }) {
    return NotesContextualActionBarState(
      actionBarOpened: actionBarOpened ?? this.actionBarOpened,
      selectedNotesIds: selectedNotesIds ?? this.selectedNotesIds,
      errorMessage: errorMessage,
      successMessage: successMessage,
      currentAction: currentAction
    );
  }
}
