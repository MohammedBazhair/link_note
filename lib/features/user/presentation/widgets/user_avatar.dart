import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/assets/app_assets.dart';
import '../../../../core/features/database/local/cache_service.dart';
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
      child: CachedNetworkImage(
        imageUrl: avatarUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        cacheManager: appImagesCacheManager,
        fadeInDuration: const Duration(milliseconds: 150),
        fadeOutDuration: const Duration(milliseconds: 150),
        placeholder: (context, url) => const PlaceholderAvatar(),
        errorWidget: (context, url, error) => const PlaceholderAvatar(),
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
