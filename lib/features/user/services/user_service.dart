import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final _instance = Supabase.instance.client.auth;

  User? get currentUser => _instance.currentUser;

}
