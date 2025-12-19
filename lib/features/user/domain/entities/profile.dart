import '../../../auth/domain/entities/sub/auth_provider.dart';

class ProfileEntity {
  ProfileEntity({
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.authProviders = const {},
  });

  factory ProfileEntity.guest() {
    return ProfileEntity(userId: '', username: '');
  }
  final String userId;
  final String username;
  final String? avatarUrl;
  final Set<AuthProvider> authProviders;

  bool get isEmailLogin => authProviders.contains(AuthProvider.email);

  ProfileEntity copyWith({
    String? userId,
    String? username,
    String? avatarUrl,
    Set<AuthProvider>? authProviders
  }) {
    return ProfileEntity(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    authProviders: authProviders?? this.authProviders
    );
  }

  @override
  String toString() =>
      'ProfileEntity(userId: $userId, username: $username, avatarUrl: $avatarUrl)';
}
