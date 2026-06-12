import 'package:flutter/material.dart';
import '../../core/extensions/extensions.dart';
import 'presentation/controllers/user_state.dart';

Future<void> userListener({
  required BuildContext context,
  required UserState? previous,
  required UserState next,
}) async {
  switch (next) {
    case UserInitialState():
    case UserUpdateProfileState():
      context.showSnakbar('تم تحديث البروفايل بنجاح');
    case UserLoadProfileState():
    case UserLoadAvatarState():
      break;
    case UserErrorState(:final message):
      context.showSnakbar(message);
  }
}
