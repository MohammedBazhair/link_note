import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/extensions.dart';
import '../../core/presentation/widgets/custom_progress_widget.dart';
import '../note/presentation/screens/notes_list_screen.dart';

import '../user/presentation/controllers/user_controller.dart';
import 'presentation/controllers/auth_state.dart';

Future<void> authListener({
  required BuildContext context,
  required AuthState? previous,
  required AuthState next,
  required WidgetRef ref,
}) async {
  switch (next) {
    case AuthInitialState():
      break;

    case AuthSuccessfullState(:final message):
      await ref.read(userControllerProvider.notifier).loadProfile();
      context.showSnakbar(message);

      await context.pushReplacementTo(const NotesListScreen());

    case AuthFailedState(:final message):
      context.pop();
      context.showSnakbar(message);

    case AuthLoadingState():
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const CustomProgressWidget(),
      );
  }
}
