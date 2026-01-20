import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/presentation/providers/core_providers.dart';
import '../../../user/domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final auth = ref.read(authControllerProvider);
  return auth;
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._auth) : super(const AuthInitialState());
  final AuthRepository _auth;

  Future<void> loginWithGoogle() async {
    state = const AuthLoadingState();

    await _auth.signInWithGoogle();
  }

  Future<void> loginWithUri(Uri uri) async {
    try {
      final result = await _auth.signInWithUrl(uri);
      if (result.hasError) throw Exception(result.errorMessage);

      state = const AuthSuccessfullState();
    } catch (e) {
      debugPrint(e.toString());
      state = AuthFailedState(e.toString());
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
    state = const AuthLoadingState();

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

  Future<void> startLoadingTimeout() async {
    await Future.delayed(const Duration(seconds: 10));
    if (mounted) {
      reset();
    }
  }

  void reset() {
    state = const AuthInitialState();
  }
}
