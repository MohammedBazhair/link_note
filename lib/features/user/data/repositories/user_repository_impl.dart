import 'package:link_note/features/user/domain/entities/profile.dart';
import 'package:link_note/features/user/data/datasources/user_remote_data_source.dart';
import 'package:link_note/features/user/domain/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  UserRepositoryImpl(this._remoteDataSource);

  @override
  bool get isUserLoggedIn => _remoteDataSource.isUserLogin;

  @override
  User? get currentUser => _remoteDataSource.currentUser;

  @override
  Future<void> createProfile(ProfileEntity profile) async {
    try {
      await _remoteDataSource.createProfile(profile);
    } catch (e) {
      throw Exception('Failed to create profile');
    }
  }

  @override
  Future<ProfileEntity> getProfile(String userId) async {
    try {
      return await _remoteDataSource.readProfile(userId);
    } catch (e) {
      throw Exception('Failed to read profile');
    }
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    try {
      
      await _remoteDataSource.updateProfile(profile);
    } catch (e) {
      throw Exception('Failed to update ${profile.username} profile');
    }
  }

  @override
  Future<ProfileEntity> uploadAvatar(
    ProfileEntity profile,
    String filePath,
  ) async {
    try {
      return await _remoteDataSource.uploadAvatarImage(profile, filePath);
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }
}
