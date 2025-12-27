import 'dart:convert';
import '../../../auth/domain/entities/sub/auth_provider.dart';
import '../../domain/entities/profile.dart';

class ProfileModel extends ProfileEntity {
  ProfileModel({
    required super.userId,
    required super.username,
    required super.updatedAt,

    this.avatarPath,
    super.avatarUrl,
    super.authProviders,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      userId: map['id'] as String,
      username: map['username'] as String,
      avatarPath: map['avatar_path'] as String?,
      updatedAt:
          map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  factory ProfileModel.fromJson(String source) {
    final map = jsonDecode(source);
    return ProfileModel.fromMap(map);
  }

  factory ProfileModel.fromEntity(ProfileEntity profile) {
    return ProfileModel(
      userId: profile.userId,
      username: profile.username,
      avatarUrl: profile.avatarUrl,
      authProviders: profile.authProviders,
      updatedAt: profile.updatedAt,
    );
  }
  final String? avatarPath;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': userId,
      'username': username,
      'updated_at': updatedAt.toIso8601String(),
      'avatar_path': ?avatarPath,
    };
  }

  String toJson() => jsonEncode(toMap());

  @override
  ProfileModel copyWith({
    String? userId,
    String? username,
    DateTime? updatedAt,
    String? avatarPath,
    String? avatarUrl,
    Set<AuthProvider>? authProviders,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      updatedAt: updatedAt ?? this.updatedAt,
      avatarPath: avatarPath ?? this.avatarPath,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      authProviders: authProviders ?? this.authProviders,
    );
  }
}
