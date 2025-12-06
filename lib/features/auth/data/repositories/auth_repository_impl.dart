import 'package:link_note/core/features/network/network_service.dart';
import 'package:link_note/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:link_note/features/auth/domain/repositories/auth_repository.dart';
import 'package:link_note/features/user/domain/entities/profile.dart';
import 'package:link_note/features/user/domain/entities/user.dart';
import 'package:link_note/features/user/domain/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final UserRepository _userRepository;
  final AuthRemoteDataSource _remote;
  final NetworkService _networkService;

  AuthRepositoryImpl(this._remote, this._networkService, this._userRepository);

  @override
  Future<String?> signUp(UserEntity user) async {
    try {
      final response = await _remote.signUp(user);
      if (response.user == null) throw AuthException('no id found');

      final profile = ProfileEntity(
        userId: response.user!.id,
        username: user.username,
      );

      await _userRepository.createProfile(profile);

      return null; // تم التسجيل بنجاح
    } on AuthException catch (e) {
      return _mapSupabaseSignUpError(e.message);
    } on Exception catch (_) {
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
    } on AuthException catch (e) {
      return _mapSupabaseSignInError(e.message);
    } on Exception {
      return 'Please check your internet connection';
    }
  }

  @override
  Future<void> signOut() {
    return _remote.signOut();
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
