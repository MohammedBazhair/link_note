import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/constants/internal_constants/log.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/features/database/local/cache_service_interface.dart';
import '../../../../core/features/database/remote/remote_database_service.dart';
import '../../../../core/features/database/remote/remote_storage_service.dart';
import '../../domain/entities/profile.dart';
import '../models/profile_model.dart';

abstract interface class UserRemoteDataSource {
  Future<void> createProfile(ProfileEntity profile);

  Future<ProfileEntity> readProfile(String? userId);

  Future<List<Map<String, dynamic>>> readProfilesBatch(List<String> usersIds);

  Future<void> updateProfile(ProfileEntity profile, [String? avatrPath]);

  Future<ProfileEntity> uploadAvatarImage(
    ProfileEntity profile,
    String filePath,
  );

  Future<Result<int>> readCredits();
  Future<void> updateCredits(int credits, String userId);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserRemoteDataSourceImpl(
    this._client,
    this._remoteDatabase,
    this._remoteStorage,
    this._locaCache,
  );
  final SupabaseClient _client;
  final RemoteDatabaseService _remoteDatabase;
  final RemoteStorageService _remoteStorage;
  final SecureCacheService _locaCache;

  @override
  Future<void> createProfile(ProfileEntity profile) {
    final profileModel = ProfileModel(
      userId: profile.userId,
      username: profile.username,
      updatedAt: profile.updatedAt,
      avatarUrl: profile.avatarUrl,
      credits: 10,
    );

    return _remoteDatabase.insertRow(
      map: profileModel.toMap(),
      table: ExternalConsts.profilesTable,
    );
  }

  @override
  Future<ProfileEntity> readProfile(String? userId) async {
    try {
      if (userId == null) throw ArgumentError.notNull('userId');

      final map = await _remoteDatabase.readRow(
        id: userId,
        column: 'id',
        table: ExternalConsts.profilesTable,
      );

      final profileModel = ProfileModel.fromMap(map);
      final imagePath = profileModel.avatarPath;

      final profileEntity = ProfileEntity(
        userId: userId,
        username: profileModel.username,
        updatedAt: profileModel.updatedAt,
        credits: profileModel.credits,
      );

      if (imagePath == null) return profileEntity;

      final avatarUrl = _remoteStorage.getUrlFrom(
        path: imagePath,
        storageBucket: ExternalConsts.imagesBucket,
      );
      return profileEntity.copyWith(avatarUrl: avatarUrl);
    } catch (e, st) {
      Logger.log(error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> updateProfile(ProfileEntity profile, [String? avatrPath]) async {
    if (profile.userId.isEmpty) throw ArgumentError.value(profile.userId);

    final profileMap = await _remoteDatabase.readRow(
      id: profile.userId,
      column: 'id',
      table: ExternalConsts.profilesTable,
    );

    final profileModel = ProfileModel.fromMap(profileMap);

    final updatedModel = profileModel.copyWith(
      authProviders: profile.authProviders,

      avatarPath: avatrPath,
      avatarUrl: profile.avatarUrl,
      username: profile.username,
      updatedAt: DateTime.now().toUtc(),
    );

    await _remoteDatabase.update(
      updated: updatedModel.toMap(),
      id: profile.userId,
      column: 'id',
      table: ExternalConsts.profilesTable,
    );
  }

  @override
  Future<ProfileEntity> uploadAvatarImage(
    ProfileEntity profile,
    String filePath,
  ) async {
    final resultPath = await _remoteStorage.uploadFile(
      filePath: filePath,
      storageBucket: ExternalConsts.imagesBucket,
      userId: profile.userId,
    );

    final avatarUrl = _remoteStorage.getUrlFrom(
      path: resultPath,
      storageBucket: ExternalConsts.imagesBucket,
    );

    final updatedProfile = profile.copyWith(avatarUrl: avatarUrl);
    await updateProfile(updatedProfile, resultPath);

    return updatedProfile;
  }

  @override
  Future<List<Map<String, dynamic>>> readProfilesBatch(
    List<String> usersIds,
  ) async {
    if (usersIds.isEmpty) return [];

    return _remoteDatabase.readRowsWhereIn(
      column: 'id',
      values: usersIds,
      table: ExternalConsts.profilesTable,
    );
  }

  @override
  Future<Result<int>> readCredits() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const UserNotLoggedInException(
          'خطأ.. قم بتسجيل الدخول أولا للاستفادة من الميزات',
        );
      }
      final map = await _remoteDatabase.readRow(
        id: userId,
        column: 'id',
        table: ExternalConsts.profilesTable,
        selectColumns: ['credits'],
      );

      final credits = (map['credits'] as int);
      await _locaCache.setString(
        key: ExternalConsts.creditsKey,
        value: '$credits',
      );
      return Result.ok(credits);
    } on UserNotLoggedInException catch (_) {
      rethrow;
    } catch (_) {
      final cachedCredits = await _locaCache.getString(
        key: ExternalConsts.creditsKey,
      );
      if (cachedCredits == null) return Result.error('خطأ في جلب عدد النقاط');
      return Result.ok(int.tryParse(cachedCredits) ?? 0);
    }
  }

  @override
  Future<void> updateCredits(int credits, String userId) async {
    try {
      final updated = {'credits': credits};

      await _remoteDatabase.update(
        updated: updated,
        id: userId,
        column: 'id',
        table: ExternalConsts.profilesTable,
      );
    } catch (e, s) {
      debugPrint('updateCredits error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }
}
