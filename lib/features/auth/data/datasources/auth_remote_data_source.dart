import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
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

  Future<AuthResponse> signInWithGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._auth, this._googleSignIn);
  final GoTrueClient _auth;
  final GoogleSignIn _googleSignIn;

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
  Future<AuthResponse> signInWithGoogle() async {
    final clientId = Platform.isAndroid
        ? ExternalConsts.androidClient
        : ExternalConsts.desktopClient;

    await _googleSignIn.initialize(
      serverClientId: ExternalConsts.webClient,
      clientId: clientId,
    );

    final account = await _googleSignIn.authenticate();

    final idToken = account.authentication.idToken ?? '';
    final authorizeScopes = await account.authorizationClient.authorizeScopes([
      'email',
      'profile',
    ]);
    final authorization = await account.authorizationClient
        .authorizationForScopes(['email', 'profile']);

    final result = await _auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: authorization?.accessToken ?? authorizeScopes.accessToken,
    );

    return result;
  }
}
