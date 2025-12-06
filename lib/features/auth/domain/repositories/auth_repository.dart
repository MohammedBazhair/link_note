import 'package:link_note/features/user/domain/entities/user.dart';

abstract interface class AuthRepository {
  Future<String?> signUp(UserEntity user);

  Future<String?> signIn({required String email, required String password});

  Future<void> signOut();
}

