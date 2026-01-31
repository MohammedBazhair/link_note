import 'package:flutter/material.dart';

import '../../../../user/presentation/widgets/user_avatar.dart';

class UserAvatarWithStatus extends StatelessWidget {
  const UserAvatarWithStatus({super.key, required this.connected,  this.radius});

  final bool connected;
  final double ?radius;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PlaceholderAvatar(radius: radius,),

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
