import 'package:supabase_flutter/supabase_flutter.dart';

import '../entities/profile.dart';

abstract interface class UserRepository {
  bool get isUserLoggedIn;
  User? get currentUser;

  Future<void> createProfile(ProfileEntity profile);

  Future<ProfileEntity> getProfile(String userId);

  Future<void> updateProfile(ProfileEntity profile);

  Future<ProfileEntity> uploadAvatar(ProfileEntity profile, String filePath);
}
