import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/result.dart';
import '../entities/get_profile_params.dart';
import '../entities/profile.dart';

abstract interface class UserRepository {
  bool get isUserLoggedIn;
  User? get currentUser;

  Future<int> getCredits();
  Future<ProfileEntity> getProfile(GetProfileParams params);

  Future<Map<String,ProfileEntity>> getProfiles(List<String> usersIds);

  Future<void> updateProfile(ProfileEntity profile);

  Future<Result<ProfileEntity>> uploadAvatar(
    ProfileEntity profile,
    String filePath,
  );
}
