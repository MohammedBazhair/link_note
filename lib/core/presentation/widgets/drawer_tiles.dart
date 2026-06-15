import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/core/presentation/widgets/loading_widget.dart';
import 'package:link_note/features/auth/auth_listeners.dart';
import 'package:link_note/features/auth/presentation/controllers/auth_state.dart';

import '../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../../features/note/presentation/controllers/note_providers.dart';
import '../../../features/note/presentation/screens/notes_list_screen.dart';
import '../../../features/offline_chat/presentation/screens/chat_list_screen.dart';
import '../../../features/session/presentation/screens/session_entry_screen.dart';
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
      title: 'تسجيل الدخول',
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
      title: 'التسجيل',
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
    ref.listen(authControllerProvider, (previous, next) {
      authListener(context: context, previous: previous, next: next, ref: ref);
    });
    final state = ref.watch(authControllerProvider);
    final loadingState = state is AuthLoadingState ? state : null;
    final isLoading = loadingState?.authLoadingType == AuthLoadingType.signOut;

    return IconButton(
      iconSize: 30,
      onPressed: isLoading
          ? null
          : ref.read(authControllerProvider.notifier).signOut,
      icon: isLoading
          ? const LoadingWidget()
          : const Icon(Icons.login_outlined),
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
      title: 'الملاحظات',
      onTap: () {
        Scaffold.of(context).closeDrawer();
        final isOpenedNow = ref.read(isInNotesListScreen);
        if (!isOpenedNow) context.pushTo(const NotesListScreen());
      },
    );
  }
}

// class ImageMemoriesTile extends ConsumerWidget {
//   const ImageMemoriesTile({super.key});

//   @override
//   Widget build(BuildContext context, ref) {
//     return DrawerTile(
//       isSelected: ref.watch(isInImageMemoriesScreen),
//       icon: Icons.photo_library_outlined,
//       title: 'ذكريات الصور',
//       onTap: () {
//         Scaffold.of(context).closeDrawer();
//         final isOpenedNow = ref.read(isInImageMemoriesScreen);
//         if (!isOpenedNow) context.pushTo(const ImageMemoriesGalleryScreen());
//       },
//     );
//   }
// }

class ManageSessionTile extends ConsumerWidget {
  const ManageSessionTile({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return DrawerTile(
      icon: Icons.meeting_room_rounded,
      title: 'إدارة الجلسة',
      onTap: () {
        context.pushTo(const SessionEntryScreen());
      },
    );
  }
}

class ChatsTile extends ConsumerWidget {
  const ChatsTile({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return DrawerTile(
      icon: Icons.chat_rounded,
      title: 'الدردشات',
      onTap: () {
        context.pushTo(const ChatListScreen());
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
      title: 'حول التطبيق',
      onTap: () {
        context.pushTo(const AboutAppScreen());
      },
    );
  }
}
