import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio/presentation/controller/audio_provider.dart';
import '../../../user/presentation/controllers/user_providers.dart';
import 'chat_providers.dart';
import 'chat_state.dart';

/// Presentation-layer controller that exposes a flat list of all messages
/// across active chat sessions. UI widgets are responsible for filtering
/// by `chatId` where needed.
class ChatController extends Notifier<ChatState> {
  @override
  ChatState build() {
    final repo = ref.watch(chatRepository);
    final myUserId = ref.watch(getUserIdProvider);
    Timer? timer;
    // Initial history
    final history = repo.chatsHistory;
    final myChatFriendsIds = repo.myChatFriendsIds(myUserId);

    final sub = repo.messages.listen((message) async {
      final isNewChatRoom = state.isNewChatRoom(message.chatId);
      final myFriendsIds = isNewChatRoom
          ? [...state.myChatFriendsIds, message.senderUserId]
          : state.myChatFriendsIds;
      state = state.copyWith(
        chatRooms: state.chatRooms,
        myChatFriendsIds: myFriendsIds,
      );
      if (timer?.isActive ?? false) return;

      timer = Timer(const Duration(seconds: 3), () {});
      await ref.read(audioControllerProvider.notifier).playBell();
    });

    ref.onDispose(() async {
      await sub.cancel();
      timer?.cancel();
    });

    return ChatState(
      chatRooms: history,
      myChatFriendsIds: myChatFriendsIds.toList(),
    );
  }

  void sendText({
    required String peerId,
    required String text,
    String? replyToMessageId,
  }) {
    ref.read(chatRepository).sendText(peerUserId: peerId, text: text);
  }

  void sendImage({required String peerId, required String filePath}) {
    ref.read(chatRepository).sendImage(peerUserId: peerId, filePath: filePath);
  }
}
