import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/handlers/chat_handshake_handler.dart';
import '../../data/handlers/chat_sending_handler.dart';
import '../../data/handlers/image_transfer_handler.dart';
import '../../data/handlers/incoming_message_handler.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/services/chat_session_manager.dart';
import '../../domain/entities/message.dart';
import 'chat_controller.dart';
import 'chat_state.dart';
import 'nearby_discovery_controller.dart';
import 'nearby_providers.dart';
import 'nearby_state.dart';

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(() {
  return ChatController();
});

final nearbyDiscoveryControllerProvider =
    NotifierProvider<NearbyDiscoveryController, NearbyState>(() {
      return NearbyDiscoveryController();
    });

final getChatMessagesProvider = Provider.family<List<Message>, String>((
  ref,
  chatId,
) {
  final chatRoom = ref.watch(
    chatControllerProvider.select((state) => state.chatRooms[chatId]),
  );

  return chatRoom?.messages.values.toList() ?? [];
});

final getMyFriendsIdsProvider = Provider((ref) {
  final chatFriendsIds = ref.watch(
    chatControllerProvider.select((state) => state.myChatFriendsIds),
  );

  return chatFriendsIds;
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
  final _incomingHandler = IncomingMessageHandler(
    _sessionManager,
    _identityManager,
    _imageHandler,
  );
  final repo = ChatRepositoryImpl(
    _connectionManager,
    _sessionManager,
    _identityManager,
    _sendingHandler,
    _handshakeHandler,
    _imageHandler,
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
//
