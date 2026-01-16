import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/constants/internal_constants/log.dart';
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
    File? tempFile;
    try {
      final file = File(filePath);
      final folderPath = file.parent.path;

      tempFile = await file.copy('$folderPath/profile.png');

      final bytesSize = await tempFile.length();
      final megasSize = bytesSize.bytesToMb;

      if (megasSize > ExternalConsts.maxfileMbSize) {
        return Result.error(
          'لا يمكن رفع الصورة الشخصية، يجب أن يكون حجم الملف أقل من ${ExternalConsts.maxfileMbSize} ميجابايت',
        );
      }

      final newProfile = await _remoteDataSource.uploadAvatarImage(
        profile,
        tempFile.path,
      );

      return Result.ok(newProfile);
    } on SocketException catch (_) {
      return Result.error(
        'لا يمكن رفع الصورة الشخصية، يرجى التحقق من اتصالك بالإنترنت أولاً.',
      );
    } catch (e) {
      Logger.log(error: e);
      return Result.error('فشل رفع الصورة الشخصية، يرجى المحاولة مرة أخرى.');
    } finally {
      if (tempFile != null) {
        if (await tempFile.exists()) await tempFile.delete();
      }
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
