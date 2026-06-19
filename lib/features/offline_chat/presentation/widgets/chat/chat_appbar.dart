import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/core/presentation/widgets/conditional_builder.dart';
import 'package:link_note/features/offline_chat/presentation/controllers/chat_providers.dart';

import '../../../../../core/constants/colors/colors.dart';
import '../../../domain/entities/nearby_identity.dart';
import '../common/user_avatar_with_status.dart';

class ChatParams {
  ChatParams({required this.identity, required this.isConnected});

  final NearbyIdentity identity;
  final bool isConnected;
}

class ChatAppbar extends ConsumerWidget {
  const ChatAppbar(this.params, {super.key});

  final ChatParams params;

  @override
  Widget build(BuildContext context, ref) {
    final isContextualOpened = ref.watch(
      chatContextualActionBarController.select((s) => s.actionBarOpened),
    );
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

      child: ConditionalBuilder(
        condition: isContextualOpened,
        builder: (_) => const ContextualChatAppBar(key: ValueKey('builder')),
        fallback: (_) =>
            DefaultChatAppbar(params, key: const ValueKey('fallback')),
      ),
    );
  }
}

class DefaultChatAppbar extends StatelessWidget {
  const DefaultChatAppbar(this.params, {super.key});

  final ChatParams params;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const BackButton(color: Colors.white),
        const SizedBox(width: 3),
        UserAvatarWithStatus(radius: 25, params: params),
        const SizedBox(width: 10),

        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 3,
            children: [
              Text(
                params.identity.displayName,
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
          onPressed: () {
            // TODO: Search message on chat screen
          },
          icon: const Icon(Icons.search, color: Colors.white),
        ),
      ],
    );
  }
}

class ContextualChatAppBar extends ConsumerWidget {
  const ContextualChatAppBar({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final contextualController = ref.read(
      chatContextualActionBarController.notifier,
    );

    return Row(
      children: [
        const BackButton(color: Colors.white),
        const SizedBox(width: 10),
        const Spacer(),
        IconButton(
          onPressed: contextualController.copyMessageText,
          icon: const Icon(Icons.copy, color: Colors.white),
        ),
      ],
    );
  }
}
