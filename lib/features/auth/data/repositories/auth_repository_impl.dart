import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/features/network/network_service.dart';
import '../../../user/domain/entities/profile.dart';
import '../../../user/domain/entities/user.dart';
import '../../../user/domain/repositories/user_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._networkService, this._userRepository);
  final UserRepository _userRepository;
  final AuthRemoteDataSource _remote;
  final NetworkService _networkService;

  @override
  Future<String?> signUp(UserEntity user) async {
    try {
      final response = await _remote.signUp(user);
      if (response.user == null) throw const AuthException('no id found');

      final profile = ProfileEntity(
        userId: response.user!.id,
        username: user.username,
      );

      await _userRepository.createProfile(profile);

      return null; // تم التسجيل بنجاح
    } on AuthException catch (e) {
      return _mapSupabaseSignUpError(e.message);
    } catch (e) {
      return 'Please check your internet connection';
    }
  }

  @override
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _remote.signIn(email: email, password: password);
      return null;
    } on AuthApiException catch (e) {
      return _mapSupabaseSignInError(e.message);
    } catch (e) {
      return 'Please try again or check your internet connection';
    }
  }

  @override
  Future<void> signOut() {
    return _remote.signOut();
  }

  @override
  Future<String?> signInWithGoogle() async {
    try {
      final response = await _remote.signInWithGoogle();
      if (response.user == null || response.session == null) {
        return 'Unable to complete Google sign in. Please try again.';
      }

      return null;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return 'Google sign-in was canceled by the user.';
      }
      return 'Google sign-in failed. Please try again later.';
    } on AuthApiException catch (_) {
      return 'Unable to sign in with Google right now. Please try again later.';
    } catch (e) {
      return 'Something went wrong. Check your internet connection and try again.';
    }
  }

  String _mapSupabaseSignInError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email or password is incorrect';
    }

    if (message.contains('Email not confirmed')) {
      return 'Please verify your email before logging in';
    }

    if (message.contains('User not found')) {
      return 'This email is not registered';
    }

    return 'Login failed, please try again';
  }

  String _mapSupabaseSignUpError(String message) {
    if (message.contains('User already registered')) {
      return 'This email is already in use';
    }

    if (message.contains('password')) {
      return 'Password must be stronger';
    }

    if (message.contains('email')) {
      return 'Please enter a valid email address';
    }

    return 'Registration failed, please try again';
  }
}
