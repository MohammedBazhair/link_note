class ChatModel {
  ChatModel({
    required this.id,
    required this.friendId,
    required this.updatedAt,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] as String,
      friendId: map['friend_id'] as String,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  final String id;
  final String friendId;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'friend_id': friendId,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ChatModel copyWith({String? id, String? friendId, DateTime? updatedAt}) {
    return ChatModel(
      id: id ?? this.id,
      friendId: friendId ?? this.friendId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
