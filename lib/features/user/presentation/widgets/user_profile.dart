import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/assets/app_images.dart';
import '../../../../core/constants/colors/colors.dart';
import '../../../../core/extensions/extensions.dart';
import '../controllers/user_controller.dart';
import '../controllers/user_state.dart';

class UserProfile extends ConsumerWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final profile = ref.watch(userControllerProvider).profile;
    final userController = ref.read(userControllerProvider.notifier);

    ref.listen(userControllerProvider, (previous, next) {
      switch (next) {
        case UserInitialState():
        case UserUpdateProfileState():
          context.showSnakbar('تم تحديث البروفايل بنجاح');
        case UserLoadProfileState():
          break;
        case UserErrorState(:final message):
          context.showSnakbar(message);
      }
    });
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: userController.pickAndUploadAvatar,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: profile.avatarUrl != null
                      ? NetworkImage(profile.avatarUrl!)
                      : const AssetImage(Assets.imagesBlankProfile),
                ),
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
    
          const SizedBox(height: 20),
          Text(profile.username),
          const SizedBox(height: 5),
          Text(userController.currentUser?.email ?? ''),
        ],
      ),
    );
  }
}
