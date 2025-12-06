import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/core/constants/assets/app_images.dart';
import 'package:link_note/core/constants/colors/colors.dart';
import 'package:link_note/features/user/presentation/controllers/user_controller.dart';

class UserProfile extends ConsumerWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final profile = ref.watch(userControllerProvider).profile;
    final userController = ref.read(userControllerProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () async => await userController.uploadAvatar(),
          child: Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: profile.avatarUrl != null
                    ? NetworkImage(profile.avatarUrl!)
                    : AssetImage(Assets.imagesBlankProfile),
              ),
              Positioned(
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

        SizedBox(height: 20),
        Text(profile.username),
        SizedBox(height: 5),
        Text(userController.currentUser?.email ?? ''),
      ],
    );
  }
}
