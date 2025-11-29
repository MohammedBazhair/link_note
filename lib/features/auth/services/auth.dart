import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _instance = Supabase.instance.client.auth;

  Future<String?> signUp({required String email, required String password}) async{
 try {
      await _instance.signUp(
        email: email,
        password: password,
      );

      return null; // تم التسجيل بنجاح
    } on AuthException catch (e) {
      return _mapSupabaseSignUpError(e.message);
    } on Exception catch (_) {
      return 'Please check your internet connection';
    }  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _instance.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return _mapSupabaseSignInError(e.message);
    } on Exception {
      return 'Please check your internet connection';
    }  }

  Future<void> signOut({required String email, required String password}) {
    return _instance.signOut();
  }
}

String _mapSupabaseSignInError(String message) {
  if (message.contains('Invalid login credentials')) {
    return 'Email or password is incorrect';
  }

  if (message.contains('Email not confirmed')) {
    return 'Please verify your email before logging in';
  }

  if (message.contains('User not found')) {
    return 'This email is not registered';
  }

  return 'Login failed, please try again';
}

String _mapSupabaseSignUpError(String message) {
  if (message.contains('User already registered')) {
    return 'This email is already in use';
  }

  if (message.contains('password')) {
    return 'Password must be stronger';
  }

  if (message.contains('email')) {
    return 'Please enter a valid email address';
  }

  return 'Registration failed, please try again';
}

