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

  void loadChatData({required String chatId, required String peerId}) {
    state = state.copyWith(currentChatId: chatId, currentPeerId: peerId);
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
    state = state.copyWith(currentMessageId: null, currentLayerLink: null);
  }

  void onEmojiSelected({required ReactionEmoji reaction}) {
    final currentMessageId = state.currentMessageId;

    if (currentMessageId == null) return;

    ref
        .read(chatControllerProvider.notifier)
        .sendReactionEmoji(
          reactionEmoji: reaction,
          messageId: currentMessageId,
        );

    hideReactionPopup();
  }
}

class ReactionEmojiState {
  ReactionEmojiState({
    this.currentLayerLink,
    this.currentMessageId,
    this.currentPeerId,
    this.currentChatId,
  });

  final String? currentPeerId;
  final String? currentChatId;
  final String? currentMessageId;
  final LayerLink? currentLayerLink;

  static const Object _sentinel = Object();

  ReactionEmojiState copyWith({
    String? currentPeerId,
    String? currentChatId,
    Object? currentMessageId = _sentinel,
    Object? currentLayerLink = _sentinel,
  }) {
    return ReactionEmojiState(
      currentPeerId: currentPeerId ?? this.currentPeerId,
      currentChatId: currentChatId ?? this.currentChatId,
      currentMessageId: identical(currentMessageId, _sentinel)
          ? this.currentMessageId
          : currentMessageId as String?,
      currentLayerLink: identical(currentLayerLink, _sentinel)
          ? this.currentLayerLink
          : currentLayerLink as LayerLink?,
    );
  }
}
