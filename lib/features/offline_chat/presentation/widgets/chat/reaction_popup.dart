import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/features/offline_chat/domain/entities/reaction_emoji.dart';

class ReactionPopup extends StatelessWidget {
  const ReactionPopup({super.key, required this.onSelected});

  final void Function(ReactionEmoji reaction) onSelected;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Durations.medium1,
      curve: Curves.easeIn,
      builder: (context, value, child) {
        final dy = 1 - value;
        return Opacity(
          opacity: value,
          child: AnimatedScale(
            scale: 0.9 + (0.1 * value),
            duration: Durations.short1,
            child: AnimatedSlide(
              offset: Offset(0, dy),
              duration: Durations.short1,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        alignment: Alignment.center,
        height: 60,
        width: 350,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(40),
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          reverse: true,
          itemCount: ReactionEmoji.values.length,
          itemBuilder: (context, index) {
            final reaction = ReactionEmoji.values[index];
            final duration = Duration(milliseconds: 300 + 100 * index);
            return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: duration,
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: EmojiIcon(
                reaction: reaction,
                onPressed: () => onSelected(reaction),
              ),
            );
          },
        ),
      ),
    );
  }
}

class EmojiIcon extends ConsumerWidget {
  const EmojiIcon({
    super.key,
    required this.reaction,
    this.size = 16,
    this.backgroundColor,
    this.borderColor,
    this.onPressed,
  });
  final ReactionEmoji reaction;
  final double size;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context, ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onPressed,

      child: CircleAvatar(
        radius: size + (size * 0.13),
        backgroundColor: borderColor ?? Colors.transparent,
        child: CircleAvatar(
          radius: size,

          backgroundColor: backgroundColor ?? Colors.transparent,
          child: Text(reaction.emoji, style: TextStyle(fontSize: size * 1.2)),
        ),
      ),
    );
  }
}
