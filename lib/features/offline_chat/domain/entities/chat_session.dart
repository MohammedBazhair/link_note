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
