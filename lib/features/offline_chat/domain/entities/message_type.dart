enum MessageType {
  handshake(1),
  text(2),
  image(3),
  voice(4),
  reactionEmoji(5);

  const MessageType(this.typeCode);
  static MessageType fromValue(int v) {
    return MessageType.values.firstWhere(
      (e) => e.typeCode == v,
      orElse: () => MessageType.text,
    );
  }

  final int typeCode;
}
