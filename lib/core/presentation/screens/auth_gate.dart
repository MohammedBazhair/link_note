import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../../features/note/presentation/screens/notes_list_screen.dart';
import '../../../features/user/presentation/controllers/user_controller.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLogged = ref.watch(userControllerProvider.notifier).isUserLoggedIn;

    return isLogged ? const NotesListScreen() : const SignInScreen();
  }
}
