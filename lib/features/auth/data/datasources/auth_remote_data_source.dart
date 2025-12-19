import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../user/domain/entities/user.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthResponse> signUp(UserEntity user);

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> signInWithGoogle();

  Future<Session> getSessionFromUrl(Uri originUrl);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._auth);
  final GoTrueClient _auth;

  @override
  Future<AuthResponse> signUp(UserEntity user) {
    return _auth.signUp(email: user.email, password: user.password);
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
  Future<Session> getSessionFromUrl(Uri originUrl) async {
    final response = await _auth.getSessionFromUrl(originUrl);

    return response.session;
  }
}
