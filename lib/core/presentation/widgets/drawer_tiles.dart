import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../../features/note/presentation/screens/notes_list_screen.dart';
import '../../../features/session/presentation/controllers/session_controller.dart';
import '../../../features/session/presentation/screens/create_session_screen.dart';
import '../../../features/session/presentation/screens/join_session_by_code_screen.dart';
import '../../../features/session/presentation/screens/session_screen.dart';
import '../../constants/colors/colors.dart';
import '../../extensions/extensions.dart';
import '../screens/about_app_screen.dart';

class DrawerTile extends StatelessWidget {
  const DrawerTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.transparent,
      leading: CircleAvatar(
        backgroundColor: isSelected ? DarkColors.primary : Colors.transparent,
        foregroundColor: isSelected ? Colors.white : DarkColors.icon,
        child: Icon(icon),
      ),
      title: Text(title),
      onTap: onTap,
    );
  }
}

class SignInTile extends StatelessWidget {
  const SignInTile({super.key});

  @override
  Widget build(BuildContext context) {
    return DrawerTile(
      icon: Icons.login,
      title: 'Login In',
      onTap: () {
        context.pushReplacementTo(const SignInScreen());
      },
    );
  }
}

class SignUpTile extends StatelessWidget {
  const SignUpTile({super.key});

  @override
  Widget build(BuildContext context) {
    return DrawerTile(
      icon: Icons.login_outlined,
      title: 'Sign Up',
      onTap: () {
        context.pushReplacementTo(const SignUpScreen());
      },
    );
  }
}

class SignOutTile extends ConsumerWidget {
  const SignOutTile({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return IconButton(
      iconSize: 30,
      onPressed: () async {
        await ref.read(authProvider.notifier).signOut();
        await context.pushReplacementTo(const SignInScreen());
      },
      icon: const Icon(Icons.login_outlined),
    );
  }
}

class NotesTile extends ConsumerWidget {
  const NotesTile({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return DrawerTile(
      isSelected: ref.watch(isInNotesListScreen),
      icon: Icons.sticky_note_2_outlined,
      title: 'Notes',
      onTap: () {
        Scaffold.of(context).closeDrawer();
        final isOpenedNow = ref.read(isInNotesListScreen);
        if (!isOpenedNow) context.pushTo(const NotesListScreen());
      },
    );
  }
}

class CreateSessionTile extends ConsumerWidget {
  const CreateSessionTile({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final session = ref.read(sessionControllerProvider).session;
    final hasSession = session != null;
    return DrawerTile(
      icon: Icons.meeting_room_rounded,
      title: hasSession ? 'Session' : 'Create Session',
      onTap: () {
        context.pushTo(
          hasSession ? const SessionScreen() : const CreateSessionScreen(),
        );
      },
    );
  }
}

class JoinSessionTile extends StatelessWidget {
  const JoinSessionTile({super.key});

  @override
  Widget build(BuildContext context) {
    return DrawerTile(
      icon: Icons.group_add_rounded,
      title: 'Join Session',
      onTap: () {
        context.pushTo(const JoinSessionByCodeScreen());
      },
    );
  }
}

class AboutAppTile extends StatelessWidget {
  const AboutAppTile({super.key});

  @override
  Widget build(BuildContext context) {
    return DrawerTile(
      icon: Icons.info,
      title: 'About',
      onTap: () {
        context.pushTo(const AboutAppScreen());
      },
    );
  }
}
