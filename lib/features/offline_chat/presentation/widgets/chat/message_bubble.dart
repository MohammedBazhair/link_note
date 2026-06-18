import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/features/offline_chat/presentation/widgets/chat/reaction_popup.dart';
import '../../../../../core/constants/internal_constants/log.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../audio/presentation/widgets/voice_message_bubble.dart';
import '../../../domain/entities/message.dart';
import '../../controllers/chat_providers.dart';
import 'message_text.dart';
import 'reply_message_widget.dart';
import 'tail_message_paint.dart';

class MessageBubble extends ConsumerWidget {
  const MessageBubble({
    super.key,
    required this.isMe,
    required this.message,
    required this.hasTail,
    this.repliedMessage,
  });

  final bool isMe;
  final Message message;
  final Message? repliedMessage;
  final bool hasTail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundColor = isMe
        ? Colors.blue.shade800
        : const Color(0xFF343147);
    final layerLink = ref.read(layerLinkProvider(message.id));
    final reactionController = ref.read(
      reactionEmojiControllerProvider.notifier,
    );
    return CompositedTransformTarget(
      link: layerLink,
      child: GestureDetector(
        onLongPress: () {
          reactionController.showReactionPopup(layerLink, message.id);
        },
        child: Align(
          alignment: isMe
              ? AlignmentDirectional.centerStart
              : AlignmentDirectional.centerEnd,
          child: Dismissible(
            key: ValueKey(message.id),
            direction: DismissDirection.endToStart,
            dismissThresholds: const {DismissDirection.endToStart: 0.5},
            confirmDismiss: (direction) {
              ref.read(replyToMessageProvider.notifier).state = message;

              return Future.value(false);
            },

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPaint(
                  painter: hasTail
                      ? TailMessagePaint(
                          isMe: isMe,
                          color: backgroundColor,
                          textDirection: Directionality.of(context),
                        )
                      : null,
                  child: IntrinsicHeight(
                    child: Container(
                      padding: EdgeInsets.all(
                        message.type == MessageType.image ? 3 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: !hasTail
                            ? BorderRadius.circular(13)
                            : BorderRadiusDirectional.only(
                                topStart: const Radius.circular(13),
                                topEnd: const Radius.circular(13),
                                bottomStart: isMe
                                    ? Radius.zero
                                    : const Radius.circular(13),
                                bottomEnd: !isMe
                                    ? Radius.zero
                                    : const Radius.circular(13),
                              ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 15,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (repliedMessage != null)
                            ReplyMessageWidget(repliedMessage: repliedMessage!),
                          MessageContnetWidget(message: message, isMe: isMe),
                        ],
                      ),
                    ),
                  ),
                ),
                if (message.reactionEmoji != null)
                  Container(
                    height: 30,
                    width: double.infinity,
                    alignment: AlignmentDirectional.topEnd,
                    child: Transform.translate(
                      offset: const Offset(10, -10),
                      child: EmojiIcon(
                        size: 14,
                        reaction: message.reactionEmoji!,
                        onPressed: () {
                          print('onPressed');
                          // TODO: Remove Emoji On Tap
                        },
                        backgroundColor: backgroundColor,
                        borderColor: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MessageContnetWidget extends StatelessWidget {
  const MessageContnetWidget({
    super.key,
    required this.message,
    required this.isMe,
  });
  final Message message;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case MessageType.handshake:
        return MessageText(text: '👋', time: message.time, isMe: isMe);

      case MessageType.text:
        return MessageText(
          text: message.text ?? '🙂',
          time: message.time,
          isMe: isMe,
        );
      case MessageType.image:
        return MessageImage(message: message);
      case MessageType.voice:
        return VoiceMessageBubble(
          path: message.filePath!,
          image: null,
          time: message.time,
        );
      case MessageType.reactionEmoji:
        return const Stack();
    }
  }
}

class MessageImage extends StatelessWidget {
  const MessageImage({super.key, required this.message});
  final Message message;
  @override
  Widget build(BuildContext context) {
    if (message.filePath == null) return const Text('صورة');

    return Container(
      clipBehavior: Clip.antiAlias,
      width: 250,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(7.5)),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 4 / 5,
            child: Image.file(
              File(message.filePath!),
              width: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                Logger.log(
                  error: 'Error loading image: $error',
                  stackTrace: stackTrace,
                );
                return Container(
                  color: Colors.black45,
                  child: const Center(child: Text('هذه الصورة غير متاحة')),
                );
              },
            ),
          ),

          PositionedDirectional(
            bottom: 8,
            end: 9,
            child: Text(
              message.time.formattedChatTime,
              style: const TextStyle(
                shadows: [
                  Shadow(blurRadius: 35, color: Color(0x993A3A3A)),
                  Shadow(blurRadius: 1, color: Color(0xAB000000)),
                ],
                fontSize: 9,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
