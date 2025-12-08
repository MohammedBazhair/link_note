import 'package:flutter/material.dart';
import '../../core/extensions/extensions.dart';
import '../note/presentation/screens/notes_list_screen.dart';

import 'presentation/controllers/auth_state.dart';

void authListener({
  required BuildContext context,
  required AuthState? previous,
  required AuthState next,
}) {
  switch (next) {
    case AuthInitialState():
      break;

    case AuthSuccessfullState(:final message):
      context.showSnakbar(message);
      context.pushReplacementTo(const NotesListScreen());

    case AuthFailedState(:final message):
      context.showSnakbar(message);
  }
}
