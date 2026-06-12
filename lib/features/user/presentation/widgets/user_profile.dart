import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/core/constants/colors/colors.dart';
import 'package:link_note/core/presentation/providers/core_providers.dart';
import 'package:link_note/features/user/domain/entities/profile.dart';
import 'package:link_note/features/user/presentation/controllers/user_controller.dart';
import 'package:link_note/features/user/user_listeners.dart';
import 'user_avatar.dart';

class UserProfileWidget extends ConsumerStatefulWidget {
  const UserProfileWidget({super.key});

  @override
  ConsumerState<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends ConsumerState<UserProfileWidget> {
  @override
  void initState() {
    super.initState();
    userController.loadProfile();
    ref.listenManual(userControllerProvider, (previous, next) {
      userListener(context: context, previous: previous, next: next);
    });
  }

  ProfileEntity get profile => ref.watch(userControllerProvider).profile;
  UserController get userController =>
      ref.read(userControllerProvider.notifier);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MouseRegion(
            cursor: profile.isEmailLogin
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: GestureDetector(
              onTap: profile.isEmailLogin
                  ? userController.pickAndUploadAvatar
                  : null,

              child: Stack(
                children: [
                  AvatarWidget(profile),

                  if (profile.isEmailLogin)
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: DarkColors.primary,
                        child: Icon(Icons.edit_rounded, size: 20),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          FittedBox(child: Text(profile.username)),
          const SizedBox(height: 5),
          FittedBox(child: Text(userController.currentUser?.email ?? '')),
        ],
      ),
    );
  }
}
