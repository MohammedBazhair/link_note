import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get_it/get_it.dart';

import '../../../user/domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

final authProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => GetIt.I<AuthController>(),
);

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._auth) : super(const AuthInitialState());
  final AuthRepository _auth;

  Future<void> loginWithGoogle() async {
    state = const AuthLoadingState();

    await _auth.signInWithGoogle();
  }

  Future<void> loginWithUri(Uri uri) async {
    try {
      final code = uri.queryParameters['code'];
      if (code == null) throw ArgumentError.notNull();

      final response = await _auth.signInWithUrl(uri);
      if (response.user?.id == null) throw ArgumentError.notNull();

      state = const AuthSuccessfullState();
    } catch (e) {
      debugPrint(e.toString());
      state = AuthFailedState(
        'Failed to login by google, try again or check your connection!',
      );
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthLoadingState();
    final error = await _auth.signIn(email: email, password: password);

    _handleState(error);
  }

  Future<void> signUp(UserEntity user) async {
    final error = await _auth.signUp(user);

    _handleState(error);
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint(e.toString());
      _handleState(e.toString());
    }
  }

  void _handleState(String? error) {
    state = error == null
        ? const AuthSuccessfullState()
        : AuthFailedState(error);
  }
}
