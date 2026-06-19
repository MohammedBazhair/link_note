import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:link_note/core/features/init_local_data_base.dart';
import 'package:link_note/features/offline_chat/data/datasources/messages_local_data_source_impl.dart';
import 'package:link_note/features/offline_chat/presentation/controllers/reaction_emoji_controller.dart';
import '../../data/handlers/chat_handshake_handler.dart';
import '../../data/handlers/chat_sending_handler.dart';
import '../../data/handlers/image_transfer_handler.dart';
import '../../data/handlers/incoming_message_handler.dart';
import '../../data/handlers/voice_transfer_handler.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/services/chat_session_manager.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/nearby_identity.dart';
import 'chat_contextual_action_bar_controller/chat_contextual_action_bar_controller.dart';
import 'chat_controller.dart';
import 'nearby_discovery_controller.dart';
import 'nearby_providers.dart';

typedef ChatMessagesMap = Map<String, Message>;

final chatControllerProvider = NotifierProvider(ChatController.new);

final nearbyDiscoveryControllerProvider = NotifierProvider(
  NearbyDiscoveryController.new,
);

final getChatMessagesProvider = Provider.family<ChatMessagesMap, String>((
  ref,
  chatId,
) {
  final chatRoom = ref.watch(
    chatControllerProvider.select((state) => state.chatRooms[chatId]),
  );

  return chatRoom?.messages ?? {};
});

final getUserNameByUserIdProvider = Provider.family<String, String>((
  ref,
  userId,
) {
  final manager = ref.watch(nearbyConnectionManagerProvider);
  final userName = manager.getDisplayNameByUserId(userId);

  return userName;
});

final getIdentityByUserIdProvider = Provider.family<NearbyIdentity, String>((
  ref,
  userId,
) {
  final manager = ref.watch(nearbyConnectionManagerProvider);
  final identity = manager.getIdentityByUserId(userId);

  return identity;
});

final getMyFriendsIdsProvider = Provider((ref) {
  final chatFriendsIds = ref.watch(
    chatControllerProvider.select((state) => state.myChatFriendsIds),
  );

  return chatFriendsIds;
});

final replyToMessageProvider = StateProvider.autoDispose<Message?>((ref) {
  return null;
});

final chatRepository = Provider((ref) {
  final _connectionManager = ref.watch(nearbyConnectionManagerProvider);
  final _sessionManager = ref.read(chatSessionManagerProvider);

  final _identityManager = ref.watch(nearbyIdentityManagerProvider);
  final _sendingHandler = ChatSendingHandler(
    _connectionManager,
    _sessionManager,
    _identityManager,
  );
  final _handshakeHandler = ChatHandshakeHandler(
    _connectionManager,
    _identityManager,
  );
  final _imageHandler = ImageTransferHandler();
  final _voiceHandler = VoiceTransferHandler();
  final _incomingHandler = IncomingMessageHandler(
    _sessionManager,
    _identityManager,
    _imageHandler,
    _voiceHandler,
  );
  final repo = ChatRepositoryImpl(
    _connectionManager,
    _sessionManager,
    _identityManager,
    _sendingHandler,
    _handshakeHandler,
    _imageHandler,
    _voiceHandler,
    _incomingHandler,
  );
  ref.onDispose(repo.dispose);

  return repo;
});

final chatSessionManagerProvider = Provider((ref) {
  final _connectionManager = ref.read(nearbyConnectionManagerProvider);
  final _identityManager = ref.read(nearbyIdentityManagerProvider);
  return ChatSessionManager(_connectionManager, _identityManager);
});

final messagesLocalDataSourceProvider = Provider((ref) {
  final _db = ref.read(localDatabaseProvider);
  return MessagesLocalDataSourceImpl(_db);
});
//

final reactionEmojiControllerProvider = NotifierProvider(
  ReactionEmojiController.new,
);

final layerLinkProvider = Provider.family<LayerLink, String>((ref, messageId) {
  return LayerLink();
});

final chatContextualActionBarController = NotifierProvider(
  ChatContextualActionBarController.new,
);
