import 'package:flutter/material.dart';

import '../../../../../core/constants/colors/colors.dart';
import '../common/user_avatar_with_status.dart';

class ChatAppbarParams {
  ChatAppbarParams({required this.personName, required this.isConnected});

  final String personName;
  final bool isConnected;
}

class ChatAppbar extends StatelessWidget {
  const ChatAppbar(this.params, {super.key});

  final ChatAppbarParams params;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.only(
        bottom: 14,
        top: 22,
        start: 5,
        end: 5,
      ),

      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF010101).withOpacity(0.15),
            offset: const Offset(0, 4),
            blurRadius: 1,
            spreadRadius: -1,
          ),
        ],
      ),
      child: Row(
        children: [
          const BackButton(color: Colors.white),
          const SizedBox(width: 3),
          UserAvatarWithStatus(connected: params.isConnected, radius: 25),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  params.personName ,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  params.isConnected ? 'متصل' : 'غير متصل',
                  style: const TextStyle(
                    color: DarkColors.secondFont,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
