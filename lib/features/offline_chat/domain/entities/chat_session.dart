import '../../data/services/nearby_connection_manager.dart';
import '../../data/services/nearby_identity_manager.dart';
import 'message.dart';

/// Domain-level description of an active chat with a peer.
///
/// This object is intentionally decoupled from any concrete
/// Bluetooth connection so that it can be used safely in
/// tests and higher layers without depending on platform APIs.
class ChatSession {
  ChatSession({
    required this.chatId,
    required this.peerUserId,
    required this.peerAddress,
  });

  factory ChatSession.create({
    required String myUserId,
    required String peerUserId,
    required String peerAddress,
  }) {
    final chatId = Message.buildChatId(myUserId, peerUserId);
    return ChatSession(
      chatId: chatId,
      peerUserId: peerUserId,
      peerAddress: peerAddress,
    );
  }

  /// Stable identifier for this chat, derived from the two userIds.
  final String chatId;

  /// Logical user id of the peer (not the Bluetooth MAC address).
  final String peerUserId;

  /// Bluetooth MAC address of the peer device.
  final String peerAddress;
}

/// In-memory manager for multiple chat sessions.
///
/// The manager is keyed by peerUserId to make it easy to route
/// user-centric actions (send message to user X) to the correct
/// underlying Bluetooth address.
class ChatSessionManager {
  ChatSessionManager(this._connectionManager, this._identityManager);

  final NearbyConnectionManager _connectionManager;

  final NearbyIdentityManager _identityManager;
  final Map<String, ChatSession> _sessions = {};

  void addSession(ChatSession session) {
    _sessions[session.peerUserId] = session;
  }

  ChatSession? getSession(String peerUserId) {
    return _sessions[peerUserId];
  }

  List<ChatSession> get allSessions => _sessions.values.toList(growable: false);

  void removeSession(String peerUserId) {
    _sessions.remove(peerUserId);
  }

  ChatSession? resolveSession(String peerUserId) {
    var session = getSession(peerUserId);

    if (session != null) return session;

    final endpointId = _connectionManager.getEndpointIdByUserId(peerUserId);

    if (endpointId != null && _connectionManager.isConnected(endpointId)) {
      session = ChatSession.create(
        myUserId: _identityManager.localIdentity.uuid,
        peerUserId: peerUserId,
        peerAddress: endpointId,
      );
      addSession(session);
    }

    return session;
  }

  void clear() {
    _sessions.clear();
  }
}
