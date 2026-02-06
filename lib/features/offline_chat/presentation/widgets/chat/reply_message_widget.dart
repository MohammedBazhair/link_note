import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/colors/colors.dart';
import '../../../domain/entities/message.dart';
import '../../controllers/chat_providers.dart';

class ReplyMessageWidget extends ConsumerWidget {
  const ReplyMessageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(replyToMessageProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),

      reverseDuration: const Duration(),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.bounceOut,

      transitionBuilder: (child, animation) {
        return SizeTransition(
          sizeFactor: animation,

          axisAlignment: -20,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: message == null
          ? const SizedBox(key: ValueKey('empty'))
          : _OverlayMessage(key: ValueKey(message.id), message: message),
    );
  }
}

class _OverlayMessage extends ConsumerWidget {
  const _OverlayMessage({required this.message, super.key});
  final Message message;

  @override
  Widget build(BuildContext context, ref) {
    return Dismissible(
      key: ValueKey(message.id),
      onDismissed: (direction) {
        ref.read(replyToMessageProvider.notifier).state = null;
      },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300.withOpacity(0.1),
              border: BoxBorder.fromSTEB(
                start: BorderSide(color: Colors.blue.shade400, width: 3),
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              message.text ?? 'يمكنك السحب لالغاء الرد',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: DarkColors.secondFont,
                fontSize: 12,
              ),
            ),
          ),

          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: CloseButton(
              onPressed: () {
                ref.read(replyToMessageProvider.notifier).state = null;
              },
              style: IconButton.styleFrom(
                iconSize: 17,
                foregroundColor: DarkColors.secondFont.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
