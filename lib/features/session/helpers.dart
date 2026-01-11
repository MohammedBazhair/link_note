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
      context.showSnakbar('تم إنشاء الجلسة بنجاح');
    case JoinSessionState():
      context.showSnakbar('تم الانضمام إلى الجلسة بنجاح');
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const CustomProgressWidget(),
      );
  }
}
