import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/assets/app_assets.dart';
import '../../../../core/presentation/widgets/conditional_builder.dart';
import '../../domain/entities/profile.dart';
import '../controllers/user_controller.dart';
import '../controllers/user_providers.dart';
import '../controllers/user_state.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget(this.profile, {super.key});

  final ProfileEntity profile;

  String? get avatarUrl => profile.avatarUrl;

  @override
  Widget build(BuildContext context) {
    return ConditionalBuilder(
      condition: avatarUrl != null,
      builder: (_) => NetworkAvatar(avatarUrl!),
      fallback: (_) => const PlaceholderAvatar(),
    );
  }
}

class NetworkAvatar extends ConsumerWidget {
  const NetworkAvatar(this.avatarUrl, {super.key});

  final String avatarUrl;

  @override
  Widget build(BuildContext context, ref) {
    final avatarAsync = ref.watch(getAvatarFileProvider(avatarUrl));
    final isLoading = ref.watch(
      userControllerProvider.select((state) => state is UserLoadAvatarState),
    );

    return ClipOval(
      child: avatarAsync.when(
        data: (avatarFile) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Image.file(
                avatarFile,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
              if (isLoading) const LoadingAvatar(),
            ],
          );
        },
        loading: () {
          return const Stack(
            alignment: AlignmentGeometry.center,
            children: [PlaceholderAvatar(), LoadingAvatar()],
          );
        },
        error: (_, _) {
          return const PlaceholderAvatar();
        },
      ),
    );
  }
}

class PlaceholderAvatar extends StatelessWidget {
  const PlaceholderAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 40,
      backgroundImage: AssetImage(Assets.imagesBlankProfile),
    );
  }
}

class LoadingAvatar extends StatelessWidget {
  const LoadingAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: const CircleAvatar(
        radius: 40,
        backgroundColor: Color(0x343D3D3D),

        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
