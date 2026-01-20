import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/extensions.dart';
import '../../core/presentation/widgets/custom_progress_widget.dart';
import '../note/presentation/screens/notes_list_screen.dart';

import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/auth_state.dart';
import 'presentation/screens/reconfirm_password_screen.dart';
import 'presentation/screens/sign_in_screen.dart';

Future<void> authListener({
  required BuildContext context,
  required AuthState? previous,
  required AuthState next,
  required WidgetRef ref,
}) async {
  if (previous is AuthLoadingState) context.pop();

  switch (next) {
    case AuthInitialState():
      break;

    case AuthSuccessfullState():
      await context.pushReplacementTo(const NotesListScreen());

    case AuthFailedState(:final message):
      context.showSnakbar(message);

    case AuthLoadingState():
      await showDialog(
        context: context,
        builder: (context) => const CustomProgressWidget(),
      );
      await ref.read(authProvider.notifier).startLoadingTimeout();
    case AuthResetPasswordSuccessfullState(:final email):
      context.showSnakbar(
        'تم ارسال رمز اعادة تعيين كلمة المرور الى بريدك الالكتروني',
      );
      await context.pushTo(ReconfirmPasswordScreen(email: email));
    case AuthPasswordChangedSuccessfullState():
      context.showSnakbar(
        'تم تغيير الباسورد بنجاح جرب تسجيل الدخول الان',
      );
      await context.pushReplacementTo(const SignInScreen());
  }
}
