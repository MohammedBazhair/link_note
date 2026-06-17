import 'package:link_note/features/auth/domain/entities/auth_state_event.dart';

import '../../../user/domain/entities/user.dart';

abstract interface class AuthRepository {
  Future<void> signUp(UserEntity user);

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  Future<void> signInWithGoogle();

  Future<void> resetPassword(String email);

  Stream<AuthStateEvent?> onAuthStateChanged();

  Future<void> updateUser({
    required String email,
    required String newPassword,
    required String nonce,
  });

  void saveUserId();
  void removerUserId();
}
