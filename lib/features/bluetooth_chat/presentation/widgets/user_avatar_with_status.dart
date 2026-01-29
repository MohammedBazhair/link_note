import 'package:flutter/material.dart';

import '../../../user/presentation/widgets/user_avatar.dart';

class UserAvatarWithStatus extends StatelessWidget {
  const UserAvatarWithStatus({super.key, required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const PlaceholderAvatar(),

        if (connected)
          const Positioned(
            left: 7,
            bottom: 2,
            child: Icon(Icons.circle, color: Colors.green, size: 16),
          ),
      ],
    );
  }
}
