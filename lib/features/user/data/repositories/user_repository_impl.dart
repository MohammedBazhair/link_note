import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._remoteDataSource);
  final UserRemoteDataSource _remoteDataSource;

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
      print(e);
      throw Exception('Failed to upload avatar');
    }
  }
}
