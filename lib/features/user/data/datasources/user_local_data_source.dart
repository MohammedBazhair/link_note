import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/features/database/local/cache_service.dart';
import '../../domain/entities/profile.dart';
import '../models/profile_model.dart';

abstract interface class UserLocalDataSource {
  Future<void> saveProfile(ProfileEntity profile);
  Future<ProfileEntity> readProfile();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  UserLocalDataSourceImpl(this._cacheService);

  final LocalCacheService _cacheService;

  @override
  Future<void> saveProfile(ProfileEntity profile) async {
    final model = ProfileModel.fromEntity(profile);
    await _cacheService.setString(
      key: ExternalConsts.profileUserKey,
      value: model.toJson(),
    );
  }

  @override
  Future<ProfileEntity> readProfile() async {
    final raw = await _cacheService.getString(
      key: ExternalConsts.profileUserKey,
    );
    if (raw == null) return ProfileEntity.guest();

    final model = ProfileModel.fromJson(raw);

    return model;
  }

}
