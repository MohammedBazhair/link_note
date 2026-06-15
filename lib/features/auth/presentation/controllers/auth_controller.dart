import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/core/constants/internal_constants/log.dart';
import 'package:link_note/features/auth/domain/entities/auth_state_event.dart';
import 'package:link_note/features/note/presentation/controllers/note_providers.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/presentation/providers/core_providers.dart';
import '../../../user/domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  late StreamSubscription<AuthStateEvent?> _onAuthChanged;

  AuthRepository get _auth => ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    _onAuthChanged = _auth.onAuthStateChanged().listen(
      _handleAuthChanges,
      onError: (e, st) {
        Logger.log(error: e, stackTrace: st);
      },
    );

    ref.onDispose(_onAuthChanged.cancel);
    return const AuthInitialState();
  }

  void _handleAuthChanges(AuthStateEvent? authEvent) async {
    switch (authEvent) {
      case AuthStateEvent.initialSession:
        state = const AuthInitialState();
      case AuthStateEvent.signedIn:
        state = const AuthSuccessfullState();
        _auth.saveUserId();
      case AuthStateEvent.signedOut:
        state = const AuthSignOutState();
        _auth.removerUserId();
        ref.invalidate(noteControllerProvider);
      case null:
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      state = const AuthLoadingState(AuthLoadingType.signWithGoogle);

      await _auth.signInWithGoogle();
    } on AppException catch (e) {
      state = AuthFailedState(e.message);
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      state = const AuthLoadingState(AuthLoadingType.signWithEmail);
      await _auth.signIn(email: email, password: password);
    } on AppException catch (e) {
      state = AuthFailedState(e.message);
    }
  }

  Future<void> signUpWithEmail(UserEntity user) async {
    try {
      state = const AuthLoadingState(AuthLoadingType.signWithEmail);

      await _auth.signUp(user);
    } on AppException catch (e) {
      state = AuthFailedState(e.message);
    }
  }

  Future<void> signOut() async {
    try {
      state = const AuthLoadingState(AuthLoadingType.signOut);
      await _auth.signOut();
      state = const AuthSignOutState();
    } on AppException catch (e) {
      state = AuthFailedState(e.message);
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AuthLoadingState(AuthLoadingType.resetPassword);
    try {
      await _auth.resetPassword(email);
      state = AuthResetPasswordSuccessfullState(email);
    } on AppException catch (e) {
      state = AuthFailedState(e.message);
    } catch (e) {
      state = AuthFailedState('فشلت عملية استعادة الباسورد حاول مرة أخرى');
    } finally {
      reset();
    }
  }

  Future<void> changePassword({
    required String email,
    required String newPassword,
    required String nonce,
  }) async {
    state = const AuthLoadingState(AuthLoadingType.resetPassword);
    try {
      await _auth.updateUser(
        email: email,
        newPassword: newPassword,
        nonce: nonce,
      );
      state = const AuthPasswordChangedSuccessfullState();
    } on AppException catch (e) {
      state = AuthFailedState(e.message);
    } catch (e) {
      state = AuthFailedState('فشلت عملية استعادة الباسورد حاول مرة أخرى');
    } finally {
      reset();
    }
  }

  void reset() {
    state = const AuthInitialState();
  }
}
