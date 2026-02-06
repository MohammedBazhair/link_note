import '../../domain/entities/message.dart';

class ChatState {
  const ChatState({required this.chatRooms, required this.myChatFriendsIds});
  final Map<String, ChatRoom> chatRooms; // {chatId: ChatRoom}
  final List<String> myChatFriendsIds;

  bool isNewChatRoom(String chatId) => !chatRooms.containsKey(chatId);

  ChatState copyWith({
    Map<String, ChatRoom>? chatRooms,
    List<String>? myChatFriendsIds,
  }) {
    return ChatState(
      chatRooms: chatRooms ?? this.chatRooms,
      myChatFriendsIds: myChatFriendsIds ?? this.myChatFriendsIds,
    );
  }
}

class ChatRoom {
  const ChatRoom({required this.messages, required this.lastUpdated});
  final Map<String, Message> messages; // {messageId: Message}
  final DateTime lastUpdated;

  ChatRoom copyWith({Map<String, Message>? messages, DateTime? lastUpdated}) {
    return ChatRoom(
      messages: messages ?? this.messages,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
