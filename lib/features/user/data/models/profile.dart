// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:link_note/features/user/domain/entities/profile.dart';

class ProfileModel extends ProfileEntity {
  final String? avatarPath;

  ProfileModel({
    required super.userId,
    required super.username,
     this.avatarPath,
    super.avatarUrl,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': userId,
      'username': username,
      'avatar_path': ?avatarPath,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      userId: map['id'] as String,
      username: map['username'] as String,
      avatarPath: map['avatar_path'] as String?,
    );
  }

@override
  ProfileModel copyWith({
    String? userId,
    String? username,
    String? avatarPath,
    String? avatarUrl,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarPath: avatarPath ?? this.avatarPath,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }


}
