// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import '../../../auth/domain/entities/sub/auth_provider.dart';
import '../../domain/entities/profile.dart';

class ProfileModel extends ProfileEntity {
  final String? avatarPath;

  ProfileModel({
    required super.userId,
    required super.username,
    this.avatarPath,
    super.avatarUrl,
    super.authProviders,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': userId,
      'username': username,
      'avatar_path': ?avatarPath,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      userId: map['id'] as String,
      username: map['username'] as String,
      avatarPath: map['avatar_path'] as String?,
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
    );
  }

  @override
  ProfileModel copyWith({
    String? userId,
    String? username,
    String? avatarPath,
    String? avatarUrl,
    Set<AuthProvider>? authProviders,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarPath: avatarPath ?? this.avatarPath,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
