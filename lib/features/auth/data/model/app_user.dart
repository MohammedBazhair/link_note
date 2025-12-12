import '../../domain/entities/app_user.dart';
import '../../domain/entities/sub/auth_provider.dart';

class AppUserModel extends AppUser {
  AppUserModel({
    required super.name,
    required super.email,
    required super.avatarUrl,
    required super.provider,
    required this.emailVerified,
    required this.googleId,
    required this.issuer,
    required this.phoneVerified,
    required this.providers,
  });

  factory AppUserModel.fromSupabase({
    required Map<String, dynamic>? userMetadata,
    required Map<String, dynamic> appMetadata,
  }) {
    final rawProviders = appMetadata['providers'] as List<dynamic>? ?? [];

    final providers = rawProviders
        .map((e) => AuthProvider.fromString(e.toString()))
        .toList();

    return AppUserModel(
      name: userMetadata?['full_name'] ?? '',
      email: userMetadata?['email'] ?? '',
      emailVerified: userMetadata?['email_verified'] ?? false,
      avatarUrl: userMetadata?['avatar_url'] ?? '',
      googleId: userMetadata?['provider_id'] ?? '',
      issuer: userMetadata?['iss'] ?? '',
      phoneVerified: userMetadata?['phone_verified'] ?? false,
      provider:  AuthProvider.fromString(appMetadata['provider'] ?? ''),
      providers: providers,
    );
  }

  final bool emailVerified;
  final String? googleId;
  final String issuer;
  final bool phoneVerified;
  final List<AuthProvider> providers;
}
