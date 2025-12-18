import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../user/domain/entities/user.dart';

abstract interface class AuthRepository {
  Future<String?> signUp(UserEntity user);

  Future<String?> signIn({required String email, required String password});

  Future<void> signOut();

  Future<void> signInWithGoogle();
    
  Future<AuthResponse> signInWithUrl(Uri uri);
}

