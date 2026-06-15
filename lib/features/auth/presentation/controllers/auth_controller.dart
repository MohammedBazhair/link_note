import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/presentation/providers/core_providers.dart';
import '../../../user/domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  AuthRepository get _auth => ref.read(authRepositoryProvider);

  @override
  AuthState build() => const AuthInitialState();

  Future<void> loginWithGoogle() async {
    try {
      state = const AuthLoadingState(AuthLoadingType.signWithGoogle);

      await _auth.signInWithGoogle();
    } on AppException catch (e) {
      _handleState(e.message);
    }
  }

  Future<void> loginWithUri(Uri uri) async {
    try {
      print('loginWithUri called');
      final authResponse = await _auth.signInWithUrl(uri);
      if (authResponse.user == null) {
        throw const AuthAppException('لا يوجد مستخدم حاليا');
      }

      state = const AuthSuccessfullState();
    } on AuthAppException catch (e) {
      _handleState(e.message);
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthLoadingState(AuthLoadingType.signWithEmail);
    final error = await _auth.signIn(email: email, password: password);

    _handleState(error);
  }

  Future<void> signUpWithEmail(UserEntity user) async {
    state = const AuthLoadingState(AuthLoadingType.signWithEmail);

    final error = await _auth.signUp(user);

    _handleState(error);
  }

  Future<void> signOut() async {
    try {
      state = const AuthLoadingState(AuthLoadingType.signOut);
      await _auth.signOut();
      state = const AuthSignOutState();
    } catch (e) {
      _handleState('حدث خطأ في الخروج حاول مرة أخرى');
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

  void _handleState(String? error) {
    state = error == null
        ? const AuthSuccessfullState()
        : AuthFailedState(error);
  }

  void reset() {
    state = const AuthInitialState();
  }
}
