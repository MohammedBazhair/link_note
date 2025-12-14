import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../upload_file/helpers/helpers.dart';
import '../../domain/entities/get_profile_params.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import 'user_state.dart';

final userControllerProvider = StateNotifierProvider<UserController, UserState>(
  (_) => GetIt.I<UserController>(),
);

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
      await Permission.camera.request();

      final file = await uploadImage();

      if (file == null) return;
      final bytesSize = await file.length();
      final megasSize = bytesSize.bytesToMb;
      if (megasSize > ExternalConsts.maxfileMbSize) {
        state = UserErrorState(
          state.profile,
          'File size must be less than 3 MB',
        );
        return;
      }
      final newProfile = await _userRepository.uploadAvatar(
        state.profile,
        file.path,
      );

      state = UserUpdateProfileState(newProfile);
    } catch (e, stack) {
      debugPrint(e.toString());
      debugPrint(stack.toString());
      state = UserErrorState(state.profile, "Can't upload avatar");
    }
  }
}
