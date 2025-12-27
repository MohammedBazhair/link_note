// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../../auth/domain/entities/sub/auth_provider.dart';

class ProfileEntity {
  ProfileEntity({
    required this.userId,
    required this.username,
    required this.updatedAt,
    this.avatarUrl,
    this.authProviders = const {},
  });

  factory ProfileEntity.guest() {
    return ProfileEntity(userId: '', username: '', updatedAt: DateTime.now());
  }
  final String userId;
  final String username;
  final String? avatarUrl;
  final Set<AuthProvider> authProviders;
  final DateTime updatedAt;

  bool get isEmailLogin => authProviders.contains(AuthProvider.email);

  ProfileEntity copyWith({
    String? userId,
    String? username,
    String? avatarUrl,
    Set<AuthProvider>? authProviders,
    DateTime? updatedAt,
  }) {
    return ProfileEntity(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      authProviders: authProviders ?? this.authProviders,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
