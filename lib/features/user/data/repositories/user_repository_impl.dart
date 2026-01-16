import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../auth/data/model/app_user.dart';
import '../../../auth/domain/entities/sub/auth_provider.dart';
import '../../domain/entities/get_profile_params.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_data_source.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._remoteDataSource, this._localDataSource);
  final UserRemoteDataSource _remoteDataSource;
  final UserLocalDataSource _localDataSource;

  @override
  bool get isUserLoggedIn => _remoteDataSource.isUserLogin;

  @override
  User? get currentUser => _remoteDataSource.currentUser;

  @override
  Future<void> createProfile(ProfileEntity profile) async {
    try {
      final appUser = AppUserModel.fromSupabase(
        userId: profile.userId,
        userMetadata: currentUser?.userMetadata,
        appMetadata: currentUser?.appMetadata ?? {},
      );

      final providers = appUser.providers.toSet();

      final ProfileEntity profileEntity;
      switch (appUser.provider) {
        case AuthProvider.google:
          profileEntity = ProfileEntity(
            userId: profile.userId,
            username: appUser.name,
            avatarUrl: appUser.avatarUrl,
            authProviders: providers,
            updatedAt: DateTime.now().toUtc(),
          );
        case AuthProvider.email:
          profileEntity = profile.copyWith(authProviders: providers);

        case AuthProvider.unknown:
          throw Exception('unKnown provider, try again');
      }

      await _localDataSource.saveProfile(profileEntity);

      await _remoteDataSource.createProfile(profile);
    } catch (e) {
      throw Exception('Failed to create profile');
    }
  }

  @override
  Future<ProfileEntity> getProfile(GetProfileParams params) async {
    try {
      final appUser = AppUserModel.fromSupabase(
        userId: params.userId,
        userMetadata: params.userMetadata,
        appMetadata: params.appMetadata,
      );
      final providers = appUser.providers.toSet();

      final ProfileEntity profileEntity;
      switch (appUser.provider) {
        case AuthProvider.email:
          final profile = await _remoteDataSource.readProfile(params.userId);
          profileEntity = profile.copyWith(authProviders: providers);
        case AuthProvider.google:
          profileEntity = ProfileEntity(
            userId: params.userId,
            username: appUser.name,
            avatarUrl: appUser.avatarUrl,
            authProviders: providers,
            updatedAt: DateTime.now().toUtc(),
          );

        case AuthProvider.unknown:
          throw Exception('unKnown provider, try again');
      }

      await _localDataSource.saveProfile(profileEntity);
      return profileEntity;
    } catch (e) {
      debugPrint(e.toString());
      return _localDataSource.readProfile();
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
  Future<Result<ProfileEntity>> uploadAvatar(
    ProfileEntity profile,
    String filePath,
  ) async {
    try {
      final file = File(filePath); //path/to/image.jpg
      final folderPath = p.dirname(file.path); // path/to

      final newFilePath = '$folderPath/${profile.userId}/profile.png';
      await file.rename(newFilePath);

      final bytesSize = await file.length();
      final megasSize = bytesSize.bytesToMb;

      if (megasSize > ExternalConsts.maxfileMbSize) {
        return Result.error(
          "Can't upload avatar, File size must be less than ${ExternalConsts.maxfileMbSize} MB",
        );
      }

      final newProfile = await _remoteDataSource.uploadAvatarImage(
        profile,
        newFilePath,
      );

      return Result.ok(newProfile);
    } on SocketException catch (_) {
      return Result.error("Can't upload avatar, check your internet first.");
    } catch (_) {
      return Result.error("Can't upload avatar, try again.");
    }
  }

  @override
  Future<Map<String, ProfileEntity>> getProfiles(List<String> usersIds) async {
    final rawProfiles = await _remoteDataSource.readProfilesBatch(usersIds);
    final appUsersModels = rawProfiles.map(AppUserModel.fromMap);

    final profiles = appUsersModels.map(ProfileEntity.fromAppUser);
    return Map.fromIterables(usersIds, profiles);
  }
}
