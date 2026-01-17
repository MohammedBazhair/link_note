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
import '../models/profile_model.dart';

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
            credits: profile.credits
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
          final profile = await _remoteDataSource.readProfile(params.userId);
      switch (appUser.provider) {
        case AuthProvider.email:
          profileEntity = profile.copyWith(authProviders: providers);
        case AuthProvider.google:
          profileEntity = ProfileEntity(
            userId: params.userId,
            username: appUser.name,
            avatarUrl: appUser.avatarUrl,
            authProviders: providers,
            credits: profile.credits
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
    if (usersIds.isEmpty) {
      return <String, ProfileEntity>{};
    }

    try {
      final rawProfiles = await _remoteDataSource.readProfilesBatch(usersIds);
      final profiles = rawProfiles
          .map<ProfileEntity>(ProfileModel.fromMap)
          .toList();

      // إنشاء map من الملفات الشخصية التي تم جلبها
      final result = <String, ProfileEntity>{};
      for (final profile in profiles) {
        result[profile.userId] = profile;
      }

      // التأكد من وجود entry لكل userId (حتى لو كان profile افتراضي)
      // هذا يضمن أن جميع الأعضاء سيظهرون حتى لو لم يكن لديهم profile في قاعدة البيانات
      for (final userId in usersIds) {
        if (!result.containsKey(userId)) {
          result[userId] = ProfileEntity(
            userId: userId,
            username: userId, // استخدام userId كاسم افتراضي
            updatedAt: DateTime.now().toUtc(),
            credits: 0
          );
        }
      }

      return result;
    } catch (e) {
      debugPrint('Error in getProfiles: $e');
      // في حالة الخطأ، إرجاع profiles افتراضية لجميع userIds
      return {
        for (final userId in usersIds)
          userId: ProfileEntity(
            userId: userId,
            username: userId,
            updatedAt: DateTime.now().toUtc(),
            credits: 0
          ),
      };
    }
  }
}
