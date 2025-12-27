import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/features/database/local/cache_service.dart';
import '../../../../core/features/network/connectivity_service.dart';
import '../../../user/domain/entities/profile.dart';
import '../../../user/domain/entities/user.dart';
import '../../../user/domain/repositories/user_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._remote,
    this._networkService,
    this._userRepository,
    this._cache,
  );
  final UserRepository _userRepository;
  final AuthRemoteDataSource _remote;
  final ConnectivityService _networkService;
  final LocalCacheService _cache;

  @override
  Future<String?> signUp(UserEntity user) async {
    try {
      final response = await _remote.signUp(user);
      if (response.user == null) throw const AuthException('no id found');

      final profile = ProfileEntity(
        userId: response.user!.id,
        username: user.username,
        updatedAt: DateTime.now()
      );

      await _userRepository.createProfile(profile);

      await _cache.setString(
        key: ExternalConsts.lastUserIdKey,
        value: profile.userId,
      );
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
      final response = await _remote.signIn(email: email, password: password);
      final userId = response.user?.id;

      if (userId != null) {
        await _cache.setString(
          key: ExternalConsts.lastUserIdKey,
          value: userId,
        );
      }
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
  Future<void> signInWithGoogle() async {
    try {
      await _remote.signInWithGoogle();
    } catch (e) {
      debugPrint(e.toString());
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

  @override
  Future<AuthResponse> signInWithUrl(Uri uri) async {
    final session = await _remote.getSessionFromUrl(uri);
    final authResponse = AuthResponse(session: session, user: session.user);

    final userId = authResponse.user?.id;

    if (userId != null) {
      await _cache.setString(key: ExternalConsts.lastUserIdKey, value: userId);
    }

    return authResponse;
  }
}
