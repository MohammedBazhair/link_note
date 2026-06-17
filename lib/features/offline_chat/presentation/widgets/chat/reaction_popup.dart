import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/features/offline_chat/domain/entities/reaction_emoji.dart';
import 'package:link_note/features/offline_chat/presentation/controllers/chat_providers.dart';

class ReactionPopup extends StatelessWidget {
  const ReactionPopup({super.key, required this.onSelected});

  final void Function(ReactionEmoji reaction) onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 60,
      width: 350,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(40),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: ReactionEmoji.values.length,
        itemBuilder: (context, index) {
          final reaction = ReactionEmoji.values[index];
          final duration = Duration(milliseconds: 200 + 100 * index);
          return TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: duration,
            curve: Curves.fastOutSlowIn,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: EmojiIcon(reaction: reaction, onSelected: onSelected),
          );
        },
      ),
    );
  }
}

class EmojiIcon extends ConsumerWidget {
  const EmojiIcon({
    super.key,
    required this.reaction,
    this.size = 16,
    required this.onSelected,
  });
  final ReactionEmoji reaction;
  final double size;
  final void Function(ReactionEmoji reaction) onSelected;

  @override
  Widget build(BuildContext context, ref) {
    final controller = ref.read(overlayPortalController);
    return IconButton(
      onPressed: () {
        onSelected(reaction);
        controller.hide();
      },

      icon: Text(reaction.emoji, style: TextStyle(fontSize: size)),
    );
  }
}
