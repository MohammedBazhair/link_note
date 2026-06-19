import 'package:equatable/equatable.dart';
import 'package:link_note/features/offline_chat/domain/entities/message.dart';

enum ChatContextualAppBarAction { copyMessage }

class ChatContextualActionBarState extends Equatable {
  const ChatContextualActionBarState({
    this.actionBarOpened = false,
    this.errorMessage,
    this.successMessage,
    this.selectedMessage,
  });

  final bool actionBarOpened;
  final Message? selectedMessage;
  final String? errorMessage;
  final String? successMessage;

  @override
  List<Object?> get props => [
    actionBarOpened,
    successMessage,
    errorMessage,
    selectedMessage,
  ];

  ChatContextualActionBarState copyWith({
    bool? actionBarOpened,
    String? errorMessage,
    String? successMessage,
    Message? selectedMessage,
  }) {
    return ChatContextualActionBarState(
      actionBarOpened: actionBarOpened ?? this.actionBarOpened,
      errorMessage: errorMessage,
      successMessage: successMessage,
      selectedMessage: selectedMessage ?? this.selectedMessage,
    );
  }
}
