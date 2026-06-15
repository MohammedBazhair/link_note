import 'package:flutter/material.dart';
import 'package:link_note/core/presentation/widgets/loading_widget.dart';

import '../../core/extensions/extensions.dart';
import 'presentation/controllers/session_state.dart';
import 'presentation/screens/active_session_screen.dart';

/// Listen for session states (loading, success, error)
Future<void> handleSessionStates(
  BuildContext context, {
  required SessionState? previous,
  required SessionState current,
}) async {
  if (previous is LoadingSessionState) context.pop();

  switch (current) {
    case InitialSessionState():
      break;
    case CreateSessionState():
      context.showSnakbar('تم إنشاء الجلسة بنجاح');
      await context.pushTo(const ActiveSessionScreen());

    case JoinSessionState():
      context.showSnakbar('تم الانضمام إلى الجلسة بنجاح');
      await context.pushTo(const ActiveSessionScreen());
    case EndedSessionState():
      context.showSnakbar('تم إنهاء الجلسة بنجاح');
      context.pop();

    case MemberLeavedSessionState():
      context.showSnakbar('العضو غادر الجلسة.');
      context.pop();

    case ErrorSessionState(:final message):
      context.showSnakbar(message);

    case AddMemberState():
      context.showSnakbar('تم إضافة العضو بنجاح');
    case LoadingSessionState():
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LoadingWidget(),
      );
  }
}
