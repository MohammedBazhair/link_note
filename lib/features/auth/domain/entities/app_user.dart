import 'sub/auth_provider.dart';

class AppUser {
  AppUser({required this.name, required this.email, required this.avatarUrl, required this.provider});

  final String name;
  final String email;
  final String? avatarUrl;
  final AuthProvider provider; // google, facebook, email...

}