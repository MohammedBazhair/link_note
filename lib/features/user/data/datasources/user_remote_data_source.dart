import 'package:flutter/widgets.dart';
import 'package:link_note/core/constants/external_constants/external_constants.dart';
import 'package:link_note/core/features/database/remote/database_service.dart';
import 'package:link_note/core/features/database/remote/storage_service.dart';
import 'package:link_note/features/user/data/models/profile.dart';
import 'package:link_note/features/user/domain/entities/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class UserRemoteDataSource {
  bool get isUserLogin;
  User? get currentUser;

  Future<void> createProfile(ProfileEntity profile);

  Future<ProfileEntity> readProfile(String? userId);

  Future<void> updateProfile(ProfileEntity profile, [String? avatrPath]);

  Future<ProfileEntity> uploadAvatarImage(
    ProfileEntity profile,
    String filePath,
  );
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final SupabaseClient _client;
  final RemoteDatabaseService _remoteDatabase;
  final RemoteStorageService _remoteStorage;

  UserRemoteDataSourceImpl(
    this._client,
    this._remoteDatabase,
    this._remoteStorage,
  );

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  bool get isUserLogin => currentUser != null;

  @override
  Future<void> createProfile(ProfileEntity profile) {
    final profileModel = ProfileModel(
      userId: profile.userId,
      username: profile.username,
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
    final profileMap = await _remoteDatabase.readRow(
      id: profile.userId,
      column: 'id',
      table: ExternalConsts.imagesBucket,
    );
    final model = ProfileModel.fromMap(profileMap);

    final newAvatarPath = avatrPath ?? model.avatarPath;

    final updatedModel = model.copyWith(avatarPath: newAvatarPath);

    return _remoteDatabase.update(
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

    await updateProfile(profile, resultPath);

    final avatarUrl = _remoteStorage.getUrlFrom(
      path: resultPath,
      storageBucket: ExternalConsts.imagesBucket,
    );
    return profile.copyWith(avatarUrl: avatarUrl);
  }
}
