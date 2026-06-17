import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/features/offline_chat/domain/entities/reaction_emoji.dart';
import 'package:link_note/features/offline_chat/presentation/controllers/chat_providers.dart';

class ReactionEmojiController extends Notifier<ReactionEmojiState> {
  final _portalController = OverlayPortalController();
  @override
  ReactionEmojiState build() {
    return ReactionEmojiState();
  }

  void showReactionPopup(LayerLink layerLink) {
    state = state.copyWith(currentLayerLink: layerLink);
    _portalController.show();
  }

  void hideReactionPopup() {
    _portalController.hide();
    state = ReactionEmojiState();
  }

  void onEmojiSelected({
    required String chatId,
    required String peerId,
    required ReactionEmoji reaction,
    required String messageId,
  }) {
    ref
        .read(chatControllerProvider.notifier)
        .sendReactionEmoji(
          chatId: chatId,
          peerId: peerId,
          reactionEmoji: reaction,
          messageId: messageId,
        );
  }
}

class ReactionEmojiState {
  ReactionEmojiState({this.currentLayerLink});

  final LayerLink? currentLayerLink;

  ReactionEmojiState copyWith({LayerLink? currentLayerLink}) {
    return ReactionEmojiState(
      currentLayerLink: currentLayerLink ?? this.currentLayerLink,
    );
  }
}
