import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../../core/presentation/widgets/conditional_builder.dart';
import '../../../../user/presentation/widgets/user_avatar.dart';
import '../chat/chat_appbar.dart';

class UserAvatarWithStatus extends StatelessWidget {
  const UserAvatarWithStatus({super.key, required this.params, this.radius});

  final ChatParams params;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AvatarBytesWidget(image: null, radius: radius),

        if (params.isConnected)
          const Positioned(
            left: 3,
            bottom: 2,
            child: Icon(Icons.circle, color: Colors.green, size: 13),
          ),
      ],
    );
  }
}

class AvatarBytesWidget extends StatelessWidget {
  const AvatarBytesWidget({
    super.key,
    required this.image,
    this.radius,
    this.icon,
  });

  final Uint8List? image;
  final double? radius;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ConditionalBuilder(
          condition: image?.isEmpty ?? true,
          builder: (_) => PlaceholderAvatar(radius: radius),
          fallback: (_) => CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: MemoryImage(image!),
            radius: radius,
          ),
        ),

        if (icon != null)
          Positioned(
            bottom: 0,
            right: -3,
            child: IconWithBackground(icon: icon!),
          ),
      ],
    );
  }
}

class IconWithBackground extends StatelessWidget {
  const IconWithBackground({super.key, required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(icon, size: 18, color: Colors.white),
        Icon(icon, size: 13, color: Colors.green),
      ],
    );
  }
}
