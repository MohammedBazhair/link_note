import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../user/data/datasources/user_remote_data_source.dart';
import '../../../user/domain/entities/user.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthResponse> signUp(UserEntity user);

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> signInWithGoogle();

  Future<AuthResponse> exchangeCodeForAuthSession(String code);

  Future<void> resetPassword(String email);

  Future<void> updateUser({
    required String email,
    required String newPassword,
    required String nonce,
    required OtpType otpType,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._auth, this._userRemote);
  final GoTrueClient _auth;
  final UserRemoteDataSource _userRemote;

  @override
  Future<AuthResponse> signUp(UserEntity user) {
    return _auth.signUp(
      email: user.email,
      password: user.password,

      data: {'full_name': user.username, 'avatar_url': null},
    );
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: ExternalConsts.authRedirectUrl,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Future<AuthResponse> exchangeCodeForAuthSession(String code) async {
    final response = await _auth.exchangeCodeForSession(code);

    return AuthResponse(session: response.session, user: response.session.user);
  }

  @override
  Future<void> resetPassword(String email) {
    return _auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> updateUser({
    required String email,
    required String newPassword,
    required String nonce,
    required OtpType otpType,
  }) async {
    try {
      await _auth.verifyOTP(type: otpType, token: nonce, email: email);

      await _auth.updateUser(
        UserAttributes(nonce: nonce, email: email, password: newPassword),
      );
    } on AuthException catch (_) {
      throw const OtpWrongException('الرمز المدخل غير صحيح');
    }
  }
}
