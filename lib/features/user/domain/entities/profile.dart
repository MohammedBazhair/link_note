import '../../../auth/data/model/app_user.dart';
import '../../../auth/domain/entities/sub/auth_provider.dart';

class ProfileEntity {
  ProfileEntity({
    required this.userId,
    required this.username,
    required this.credits,
    
     this.updatedAt,
    this.avatarUrl,
    this.authProviders = const {},
  });

  factory ProfileEntity.guest() {
    return ProfileEntity(
      userId: '',
      username: '',
      updatedAt: DateTime.now().toUtc(),
      credits: 0
    );
  }

  factory ProfileEntity.fromAppUser(AppUserModel model) {
    return ProfileEntity(
      userId: model.userId,
      username: model.userId,
      updatedAt: model.updatedAt,
      authProviders: model.providers.toSet(),
      avatarUrl: model.avatarUrl,
      credits: 0
    );
  }

  final String userId;
  final String username;
  final String? avatarUrl;
  final Set<AuthProvider> authProviders;
  final DateTime? updatedAt;
  final int credits;

  bool get isEmailLogin => authProviders.contains(AuthProvider.email);

  ProfileEntity copyWith({
    String? userId,
    String? username,
    String? avatarUrl,
    Set<AuthProvider>? authProviders,
    DateTime? updatedAt,
    int? credits,
  }) {
    return ProfileEntity(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      authProviders: authProviders ?? this.authProviders,
      updatedAt: updatedAt ?? this.updatedAt,
      credits: credits ??this.credits
    );
  }
}
