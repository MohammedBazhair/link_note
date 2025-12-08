import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../user/domain/entities/user.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthResponse> signUp(UserEntity user);

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();
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
}

