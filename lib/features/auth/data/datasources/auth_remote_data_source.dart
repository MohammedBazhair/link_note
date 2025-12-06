import 'package:link_note/features/user/domain/entities/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthResponse> signUp(UserEntity user);

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Supabase _dataSource;

  AuthRemoteDataSourceImpl(this._dataSource);

  GoTrueClient get _auth => _dataSource.client.auth;

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

