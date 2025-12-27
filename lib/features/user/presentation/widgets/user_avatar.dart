import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../../../core/constants/assets/app_assets.dart';
import '../../../../core/presentation/widgets/conditional_builder.dart';
import '../../domain/entities/profile.dart';

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

class NetworkAvatar extends StatelessWidget {
  const NetworkAvatar(this.avatarUrl, {super.key});

  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: FutureBuilder(
        future: DefaultCacheManager().getSingleFile(avatarUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const PlaceholderAvatar();
          }

          if (!snapshot.hasData || snapshot.hasError) {
            return const PlaceholderAvatar();
          }

          return Image.file(
            snapshot.data!,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          );
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
