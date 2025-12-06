class ProfileEntity {
  final String userId;
  final String username;
  final String? avatarUrl;

  ProfileEntity({required this.userId, required this.username, this.avatarUrl});
  
  factory ProfileEntity.guest() {
    return ProfileEntity(userId: '', username: '');
  }

  ProfileEntity copyWith({
    String? userId,
    String? username,
    String? avatarUrl,
  }) {
    return ProfileEntity(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
