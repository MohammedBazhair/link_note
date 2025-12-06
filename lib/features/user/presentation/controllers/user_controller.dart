import 'package:flutter_riverpod/legacy.dart';
import 'package:get_it/get_it.dart';
import 'package:link_note/features/upload_file/helpers/helpers.dart';
import 'package:link_note/features/user/domain/entities/profile.dart';
import 'package:link_note/features/user/domain/repositories/user_repository.dart';
import 'package:link_note/features/user/presentation/controllers/user_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userControllerProvider = StateNotifierProvider<UserController, UserState>(
  (ref) {
    return GetIt.I<UserController>();
  },
);

class UserController extends StateNotifier<UserState> {
  final UserRepository _userRepository;
  UserController(this._userRepository) : super(UserInitialState());

  bool get isUserLoggedIn => _userRepository.isUserLoggedIn;

  User? get currentUser => _userRepository.currentUser;

  Future<void> createProfile(ProfileEntity profile) async {
    try {
      await _userRepository.createProfile(profile);
    } catch (e) {
      state = UserErrorState(state.profile, e.toString());
    }
  }

  Future<void> loadProfile(String userId) async {
    try {
      final newProfile = await _userRepository.getProfile(userId);

      state = UserLoadProfileState(newProfile);
    } catch (e) {
      state = UserErrorState(state.profile, 'cant get profile error');
    }
  }

  Future<void> updateProfile(ProfileEntity newProfile) async {
    try {
      await _userRepository.updateProfile(newProfile);

      state = UserUpdateProfileState(newProfile);
    } catch (e) {
      state = UserErrorState(state.profile, e.toString());
    }
  }

  Future<void> uploadAvatar() async {
    try {
      final file = await uploadImage();
      if (file == null) return;

      final newProfile = await _userRepository.uploadAvatar(
        state.profile,
        file.path,
      );

      state = UserUpdateProfileState(newProfile);
    } catch (e) {
      state = UserErrorState(state.profile, "Can't upload avatar");
    }
  }
}
