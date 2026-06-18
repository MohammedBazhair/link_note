// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:link_note/features/offline_chat/domain/entities/reaction_emoji.dart';
import 'package:link_note/features/offline_chat/presentation/controllers/chat_providers.dart';

class ReactionEmojiController extends Notifier<ReactionEmojiState> {
  final portalController = OverlayPortalController();
  @override
  ReactionEmojiState build() {
    return ReactionEmojiState();
  }

  void showReactionPopup(LayerLink layerLink, String messageId) {
    state = state.copyWith(
      currentLayerLink: layerLink,
      currentMessageId: messageId,
    );
    portalController.show();
  }

  void hideReactionPopup() {
    portalController.hide();
    state = ReactionEmojiState();
  }

  void onEmojiSelected({
    required String chatId,
    required String peerId,
    required ReactionEmoji reaction,
  }) {
    final currentMessageId = state.currentMessageId;

    if (currentMessageId == null) return;

    ref
        .read(chatControllerProvider.notifier)
        .sendReactionEmoji(
          chatId: chatId,
          peerId: peerId,
          reactionEmoji: reaction,
          messageId:currentMessageId,
        );
  }
}

class ReactionEmojiState {
  ReactionEmojiState({this.currentLayerLink, this.currentMessageId});

  final String? currentMessageId;
  final LayerLink? currentLayerLink;

  ReactionEmojiState copyWith({
    String? currentMessageId,
    LayerLink? currentLayerLink,
  }) {
    return ReactionEmojiState(
      currentMessageId: currentMessageId ?? this.currentMessageId,
      currentLayerLink: currentLayerLink ?? this.currentLayerLink,
    );
  }
}
