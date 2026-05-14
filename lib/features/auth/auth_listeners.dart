import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/extensions.dart';
import '../note/presentation/screens/notes_list_screen.dart';
import 'presentation/controllers/auth_state.dart';
import 'presentation/screens/reconfirm_password_screen.dart';
import 'presentation/screens/sign_in_screen.dart';

Future<void> authListener({
  required BuildContext context,
  required AuthState? previous,
  required AuthState next,
  required WidgetRef ref,
}) async {
  switch (next) {
    case AuthInitialState():
      break;

    case AuthSuccessfullState():
      await context.pushReplacementTo(const NotesListScreen());

    case AuthFailedState(:final message):
      context.showSnakbar(message);

    case AuthLoadingState():
      break;
    case AuthResetPasswordSuccessfullState(:final email):
      context.showSnakbar(
        'تم ارسال رمز اعادة تعيين كلمة المرور الى بريدك الالكتروني',
      );
      await context.pushTo(ReconfirmPasswordScreen(email: email));
    case AuthPasswordChangedSuccessfullState():
      context.showSnakbar('تم تغيير الباسورد بنجاح جرب تسجيل الدخول الان');
      await context.pushReplacementTo(const SignInScreen());
    case AuthSignOutState():
      await context.pushReplacementTo(const SignInScreen());
  }
}
