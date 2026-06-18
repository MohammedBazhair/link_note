import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/core/utils/debouncer.dart';
import 'package:link_note/features/offline_chat/domain/entities/reaction_emoji.dart';

import '../../../audio/presentation/controller/audio_provider.dart';
import '../../../user/presentation/controllers/user_providers.dart';
import '../../domain/entities/message.dart';
import 'chat_providers.dart';
import 'chat_state.dart';

class ChatController extends Notifier<ChatState> {
  StreamSubscription<Message>? _messageSubscription;
  final _notificationDebounce = Debouncer(milliseconds: 200);

  @override
  ChatState build() {
    // Watch repository and userId to rebuild when they change
    final repository = ref.watch(chatRepository);
    final myUserId = ref.watch(getUserIdProvider);

    // Initial setup or re-build: cancel old subscription
    _messageSubscription?.cancel();

    // Listen for new messages from the repository stream
    _messageSubscription = repository.messages.listen(_onMessageReceived);

    ref.onDispose(() {
      _messageSubscription?.cancel();
      _notificationDebounce.dispose();
    });

    // Populate initial state from repository history
    return ChatState(
      chatRooms: repository.chatsHistory,
      myChatFriendsIds: repository.myChatFriendsIds(myUserId).toList(),
    );
  }

  void _onMessageReceived(Message message) {
    final isNewChatRoom = state.isNewChatRoom(message.chatId);
    final myFriendsIds = isNewChatRoom
        ? [...state.myChatFriendsIds, message.senderUserId]
        : state.myChatFriendsIds;

    // Immunitably update the chat rooms map
    final currentMessages = state.chatRooms[message.chatId]?.messages ?? {};
    final updatedMessages = {...currentMessages};

    updatedMessages.update(
      message.id,
      (current) {
        if (message.type == MessageType.reactionEmoji) {
          return current.copyWith(reactionEmoji: message.reactionEmoji);
        }
        return current;
      },
      ifAbsent: () {
        return message;
      },
    );

    final updatedChatRooms = {...state.chatRooms};
    updatedChatRooms.update(
      message.chatId,
      (room) =>
          room.copyWith(messages: updatedMessages, lastUpdated: DateTime.now()),
      ifAbsent: () =>
          ChatRoom(messages: updatedMessages, lastUpdated: DateTime.now()),
    );

    state = state.copyWith(
      chatRooms: updatedChatRooms,
      myChatFriendsIds: myFriendsIds,
    );

    _notificationDebounce.run(
      ref.read(audioControllerProvider.notifier).playBell,
    );
  }

  void sendText({
    required String peerId,
    required String text,
    String? replyToMessageId,
  }) {
    ref
        .read(chatRepository)
        .sendText(
          peerUserId: peerId,
          text: text,
          replyToMessageId: replyToMessageId,
        );
  }

  void sendImage({
    required String peerId,
    required String filePath,
    String? replyToMessageId,
  }) {
    ref
        .read(chatRepository)
        .sendImage(
          peerUserId: peerId,
          filePath: filePath,
          replyToMessageId: replyToMessageId,
        );
  }

  void sendVoiceRecord({
    required String peerId,
    required String filePath,
    String? replyToMessageId,
  }) {
    ref
        .read(chatRepository)
        .sendVoiceRecord(
          peerUserId: peerId,
          filePath: filePath,
          replyToMessageId: replyToMessageId,
        );
  }

  void sendReactionEmoji({
    required ReactionEmoji? reactionEmoji,
    required String messageId,
  }) {
    final chatId = ref.read(reactionEmojiControllerProvider).currentChatId;
    final peerId = ref.read(reactionEmojiControllerProvider).currentPeerId;
    if (chatId == null|| peerId == null) return;

    final currentMessage = state.chatRooms[chatId]?.messages[messageId];
    if (currentMessage == null) return;

    ref
        .read(chatRepository)
        .sendEmoji(
          peerUserId: peerId,
          reactionEmoji: reactionEmoji,
          messageId: messageId,
        );

  }
}
