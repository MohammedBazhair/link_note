import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/colors/colors.dart';
import '../../../../user/presentation/controllers/user_providers.dart';
import '../../../domain/entities/message.dart';
import '../../controllers/chat_providers.dart';

class ReplyMessageWidget extends StatelessWidget {
  const ReplyMessageWidget({
    super.key,
    this.repliedMessage,
    this.hasCloseIcon = false,
  });
  final Message? repliedMessage;
  final bool hasCloseIcon;
  @override
  Widget build(BuildContext context) {
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
      child: repliedMessage == null
          ? const SizedBox(key: ValueKey('empty'))
          : _OverlayMessage(
              key: ValueKey(repliedMessage!.id),
              message: repliedMessage!,
              hasCloseIcon: hasCloseIcon,
            ),
    );
  }
}

class _OverlayMessage extends ConsumerWidget {
  const _OverlayMessage({
    required this.message,
    super.key,
    this.hasCloseIcon = false,
  });
  final Message message;
  final bool hasCloseIcon;

  @override
  Widget build(BuildContext context, ref) {
    final myId = ref.watch(getUserIdProvider);
    final isMe = message.senderUserId == myId;
    final primaryColor = isMe ? Colors.blue.shade400 : Colors.blue.shade100;

    final senderName = isMe
        ? 'أنت'
        : ref.watch(getUserNameByUserIdProvider(message.senderUserId));
    return Stack(
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          width: double.infinity,
          margin: const EdgeInsets.only(top: 7, bottom: 10, right: 3, left: 3),
          padding: const EdgeInsetsDirectional.only(start: 10),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.15),
            border: BoxBorder.fromSTEB(
              start: BorderSide(color: primaryColor, width: 5),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            spacing: 10,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 7,
                    children: [
                      Text(
                        isMe ? 'أنت' : senderName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: primaryColor..withAlpha(240),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _RepliedContent(message),
                    ],
                  ),
                ),
              ),

              if (message.type == MessageType.image)
                Image.asset(
                  message.filePath!,
                  width: 70,
                  height: 70,

                  fit: BoxFit.cover,
                ),
            ],
          ),
        ),

        if (hasCloseIcon)
          PositionedDirectional(
            end: 5,
            top: 5,
            child: CloseButton(
              onPressed: () {
                ref.read(replyToMessageProvider.notifier).state = null;
              },
              style: IconButton.styleFrom(
                iconSize: 17,
                foregroundColor: DarkColors.secondFont.withOpacity(0.5),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                overlayColor: Colors.transparent,
              ),
            ),
          ),
      ],
    );
  }
}

class _RepliedContent extends StatelessWidget {
  const _RepliedContent(this.message);
  final Message message;
  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      letterSpacing: 0.45,
      color: Color(0xD7CECECE),
      fontSize: 10,
    );
    switch (message.type) {
      case MessageType.handshake:
        return const Text(
          'يمكنك ضغط زر الاغلاق لالغاء الرد',

          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: style,
        );
      case MessageType.text:
        return Text(
          message.text ?? '...',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: style,
        );

      case MessageType.image:
        return const Row(
          spacing: 8,
          children: [
            Icon(Icons.photo),
            Text(
              'صورة',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ],
        );
    }
  }
}
