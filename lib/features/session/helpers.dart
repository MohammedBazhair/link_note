import 'package:flutter/material.dart';

import '../../core/extensions/extensions.dart';
import '../../core/presentation/widgets/custom_progress_widget.dart';
import 'presentation/controllers/session_state.dart';

void handleSessionStates(
  BuildContext context, {
  required SessionState? previous,
  required SessionState current,
}) {
  if (previous is LoadingSessionState) context.pop();

  switch (current) {
    case InitialSessionState():
      break;
    case CreateSessionState():
      context.showSnakbar('Session created successfully');
    case JoinSessionState():
      context.showSnakbar('Joined session successfully');
    case EndedSessionState():
      context.showSnakbar('Ended session successfully');
      context.pop();
    case MemberLeavedSessionState():
      context.showSnakbar('Member leaved session.');
      context.pop();

    case ErrorSessionState(:final message):
      context.showSnakbar(message);
    case AddMemberState():
      context.showSnakbar('Member added successfully');
    case LoadingSessionState():
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const CustomProgressWidget(),
      );
  }
}
