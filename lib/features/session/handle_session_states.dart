import 'package:flutter/material.dart';

import '../../core/extensions/extensions.dart';
import '../../core/presentation/widgets/custom_progress_widget.dart';
import 'presentation/controllers/session_state.dart';
import 'presentation/screens/session_screen.dart';

/// Listen for session states (loading, success, error)
Future<void> handleSessionStates(
  BuildContext context, {
  required SessionState? previous,
  required SessionState current,
}) async {
  switch (current) {
    case InitialSessionState():
      break;
    case CreateSessionState():
      context.showSnakbar('تم إنشاء الجلسة بنجاح');
      context.pop();
      await context.pushTo(const SessionScreen());
    case JoinSessionState():
      context.showSnakbar('تم الانضمام إلى الجلسة بنجاح');
      context.pop();
      await context.pushTo(const SessionScreen());
    case EndedSessionState():
      context.showSnakbar('تم إنهاء الجلسة بنجاح');
      context.pop();
    case MemberLeavedSessionState():
      context.showSnakbar('العضو غادر الجلسة.');
      context.pop();


    case ErrorSessionState(:final message):
      context.showSnakbar(message);
      context.pop();
    case AddMemberState():
      context.showSnakbar('تم إضافة العضو بنجاح');
    case LoadingSessionState():
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const CustomProgressWidget(),
      );
  }
}
