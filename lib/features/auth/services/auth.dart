import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _instance = Supabase.instance.client.auth;


  Future<void> signUp({required String email, required String password}) {
   return _instance.signUp(password: password,email: email);
  }

  Future<void> signIn({required String email, required String password}) {
   return _instance.signInWithPassword(password: password,email: email);
  }

 Future< void> signOut({required String email, required String password}) {
   return _instance.signOut();
  }


}
