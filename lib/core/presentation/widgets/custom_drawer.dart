import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/note/presentation/controllers/note_providers.dart';
import '../../../features/user/presentation/widgets/user_profile.dart';
import '../../constants/colors/colors.dart';
import '../providers/core_providers.dart';
import 'drawer_tiles.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isUserLogin = ref
        .watch(userControllerProvider.notifier)
        .isUserLoggedIn;
    final userController = ref.read(userControllerProvider.notifier);
    final isSelectable = ref.watch(
      selectableNoteProvider.select((s) => s.isSelectable),
    );

    if (isSelectable) return const SizedBox.shrink();
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 30,
          bottom: 12,
          left: 12,
          right: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RefreshIndicator(
                    color: DarkColors.primary,
                    onRefresh: userController.loadProfile,
                    child: ListView(
                      children: [
                        if (isUserLogin) ...[
                          const UserProfileWidget(),
                          const Divider(),
                        ] else ...[
                          const SizedBox(height: 35),
                          const SignInTile(),
                          const SignUpTile(),
                        ],
                        const NotesTile(),
                        if (!Platform.isWindows) const ChatsTile(),
                        // const ImageMemoriesTile(),
                        if (isUserLogin) ...[const ManageSessionTile()],
                        const AboutAppTile(),
                      ],
                    ),
                  ),

                  PositionedDirectional(
                    top: 30,
                    end: 10,

                    child: IconButton(
                      iconSize: 27,
                      onPressed: Scaffold.of(context).closeDrawer,
                      icon: const Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                ],
              ),
            ),
            if (isUserLogin) const SignOutTile(),
          ],
        ),
      ),
    );
  }
}
