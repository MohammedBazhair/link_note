import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../user/presentation/widgets/user_avatar.dart';
import '../chat/chat_appbar.dart';

class UserAvatarWithStatus extends StatelessWidget {
  const UserAvatarWithStatus({
    super.key,
    required this.params,
    this.radius,
  });

  final ChatParams params;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AvatarBytesWidget(image: params.identity.avatarBytes, radius: radius),

        if (params.isConnected)
          const Positioned(
            left: 7,
            bottom: 2,
            child: Icon(Icons.circle, color: Colors.green, size: 16),
          ),
      ],
    );
  }
}

class AvatarBytesWidget extends StatelessWidget {
  const AvatarBytesWidget({super.key, required this.image, this.radius});

  final Uint8List? image;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    if (image?.isEmpty ?? true) {
      return PlaceholderAvatar(radius: radius);
    }

    return CircleAvatar(
      backgroundColor: Colors.white,
      backgroundImage: MemoryImage(image!),
      radius: radius,
    );
  }
}
