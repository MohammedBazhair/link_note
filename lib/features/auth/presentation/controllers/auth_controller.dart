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
  AuthController(this._auth) : super(AuthInitialState());
  final AuthRepository _auth;

  Future<void> login({required String email, required String password}) async {
    final error = await _auth.signIn(email: email, password: password);

    error == null
        ? _handleState('Login In Successfully')
        : _handleState(error, true);
  }

  Future<void> signUp(UserEntity user) async {
    final error = await _auth.signUp(user);

    error == null
        ? _handleState('Sign up Successfully')
        : _handleState(error, true);
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();

      _handleState('Sign out Successfully');
    } catch (e) {
      debugPrint(e.toString());
      _handleState('An error occurred while signing out.', true);
    }
  }

  void _handleState(String message, [bool hasError = false]) {
    state = hasError ? AuthFailedState(message) : AuthSuccessfullState(message);
  }
}
