import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/features/database/remote/remote_database_service.dart';
import '../../../../core/features/database/remote/remote_storage_service.dart';
import '../../domain/entities/profile.dart';
import '../models/profile_model.dart';

abstract interface class UserRemoteDataSource {
  bool get isUserLogin;
  User? get currentUser;

  Future<void> createProfile(ProfileEntity profile);

  Future<ProfileEntity> readProfile(String? userId);

  Future<List<Map<String, dynamic>>> readProfilesBatch(List<String> usersIds);

  Future<void> updateProfile(ProfileEntity profile, [String? avatrPath]);

  Future<ProfileEntity> uploadAvatarImage(
    ProfileEntity profile,
    String filePath,
  );
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserRemoteDataSourceImpl(
    this._client,
    this._remoteDatabase,
    this._remoteStorage,
  );
  final SupabaseClient _client;
  final RemoteDatabaseService _remoteDatabase;
  final RemoteStorageService _remoteStorage;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  bool get isUserLogin => currentUser != null;

  @override
  Future<void> createProfile(ProfileEntity profile) {
    final profileModel = ProfileModel(
      userId: profile.userId,
      username: profile.username,
      updatedAt: profile.updatedAt,
      avatarUrl: profile.avatarUrl,
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
      );

      if (imagePath == null) return profileEntity;

      final avatarUrl = _remoteStorage.getUrlFrom(
        path: imagePath,
        storageBucket: ExternalConsts.imagesBucket,
      );
      return profileEntity.copyWith(avatarUrl: avatarUrl);
    } catch (e) {
      debugPrint(e.toString());

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
    );

    final avatarUrl = _remoteStorage.getUrlFrom(
      path: resultPath,
      storageBucket: ExternalConsts.imagesBucket,
    );
    print('AVATAR URL: $avatarUrl');

    final updatedProfile = profile.copyWith(avatarUrl: avatarUrl);
    await updateProfile(profile, resultPath);

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
      table: ExternalConsts.usersTable,
      columnsSelect: 'id, email, raw_app_meta_data, raw_user_meta_data',
    );
  }
}
