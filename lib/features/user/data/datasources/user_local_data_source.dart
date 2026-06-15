import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/features/database/local/cache_service_interface.dart';
import '../../domain/entities/profile.dart';
import '../models/profile_model.dart';

abstract interface class UserLocalDataSource {
  Future<void> saveProfile(ProfileEntity profile);
  Future<void> saveCredits(int credits);
  Future<int> readCredits();
  Future<ProfileEntity> readProfile();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  UserLocalDataSourceImpl(this._cacheService);

  final SecureCacheService _cacheService;

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

  @override
  Future<int> readCredits() async {
    final raw = await _cacheService.getString(key: ExternalConsts.creditsKey);

    if (raw == null) return 0;

    return int.tryParse(raw) ?? 0;
  }

  @override
  Future<void> saveCredits(int credits) {
    return _cacheService.setString(
      key: ExternalConsts.creditsKey,
      value: '$credits',
    );
  }
}
