import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../../features/note/presentation/screens/notes_list_screen.dart';
import '../../../features/session/presentation/controllers/session_controller.dart';
import '../../../features/session/presentation/screens/create_session_screen.dart';
import '../../../features/session/presentation/screens/session_screen.dart';
import '../../../features/user/presentation/controllers/user_controller.dart';
import '../../../features/user/presentation/widgets/user_profile.dart';
import '../../extensions/extensions.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isUserLogin = ref
        .watch(userControllerProvider.notifier)
        .isUserLoggedIn;
    final userController = ref.read(userControllerProvider.notifier);

    return Drawer(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 50,
          right: 12,
          bottom: 12,
          left: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await userController.loadProfile();
                },
                child: ListView(
                  children: [
                    if (isUserLogin) ...[
                      const UserProfileWidget(),
                      const Divider(),
                    ] else ...[
                      const SignInTile(),
                      const SignUpTile(),
                    ],
                    const NotesTile(),
                    if (isUserLogin) const SessionTile(),
                  ],
                ),
              ),
            ),
            if (isUserLogin) const SignOutTile(),
          ],
        ),
      ),
    );
  }
}

class DrawerTile extends StatelessWidget {
  const DrawerTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.transparent,
      leading: Icon(icon),
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

class NotesTile extends StatelessWidget {
  const NotesTile({super.key});

  @override
  Widget build(BuildContext context) {
    return DrawerTile(
      icon: Icons.sticky_note_2_outlined,
      title: 'Notes',
      onTap: () {
        context.pushReplacementTo(const NotesListScreen());
      },
    );
  }
}

class SessionTile extends ConsumerWidget {
  const SessionTile({super.key});

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
