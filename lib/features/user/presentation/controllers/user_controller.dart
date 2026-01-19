import 'dart:io';

import 'package:flutter_riverpod/legacy.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../upload_file/helpers/helpers.dart';
import '../../domain/entities/get_profile_params.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import 'user_state.dart';

class UserController extends StateNotifier<UserState> {
  UserController(this._userRepository) : super(UserInitialState());
  final UserRepository _userRepository;

  bool get isUserLoggedIn => _userRepository.isUserLoggedIn;

  User? get currentUser => _userRepository.currentUser;

  Future<void> createProfile(UserEntity user) async {
    try {
      if (currentUser?.id == null) throw ArgumentError.notNull();
      final profile = ProfileEntity(
        userId: currentUser!.id,
        username: user.username,
        updatedAt: DateTime.now().toUtc(),
        credits: 10,
      );
      await _userRepository.createProfile(profile);
    } catch (e) {
      state = UserErrorState(
        state.profile,
        'Error: Can\' create profile ${user.username}',
      );
    }
  }

  Future<void> loadProfile() async {
    try {
      if (currentUser?.id == null) return;

      final profileParams = GetProfileParams(
        userId: currentUser!.id,
        appMetadata: currentUser!.appMetadata,
        userMetadata: currentUser?.userMetadata,
      );

      final newProfile = await _userRepository.getProfile(profileParams);

      state = UserLoadProfileState(newProfile);
    } catch (e, _) {
      state = UserErrorState(state.profile, 'Can\'t get profile error');
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

  Future<void> pickAndUploadAvatar() async {
    try {
      if (!Platform.isWindows) await Permission.camera.request();

      final file = await uploadImage();
      if (file == null) return;
      state = UserLoadAvatarState(state.profile);

      final result = await _userRepository.uploadAvatar(
        state.profile,
        file.path,
      );

      if (result.hasError) throw Exception(result.errorMessage);

      state = UserUpdateProfileState(result.value!);
    } catch (e) {
      state = UserErrorState(state.profile, e.toString());
    }
  }
}
