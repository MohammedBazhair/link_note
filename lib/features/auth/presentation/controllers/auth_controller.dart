import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get_it/get_it.dart';
import 'package:link_note/features/auth/domain/repositories/auth_repository.dart';
import 'package:link_note/features/auth/presentation/controllers/auth_state.dart';
import 'package:link_note/features/user/domain/entities/user.dart';

final authProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => GetIt.I<AuthController>(),
);

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _auth;
  AuthController(this._auth) : super(AuthInitialState());

  Future<void> login({required String email, required String password}) async {
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

      _handleState(null);
    } catch (e) {
      debugPrint(e.toString());
      _handleState('An error occurred while signing out.');
    }
  }

  void _handleState(String? error) {
    if (error == null) {
      state = AuthSuccessfullState();
      return;
    }

    state = AuthFailedState(error);
  }
}
