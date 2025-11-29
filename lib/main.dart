import 'package:flutter/material.dart';
import 'package:link_note/core/presentation/screens/home_screen.dart';
import 'package:link_note/core/theme/dark_theme.dart';
import 'package:link_note/features/user/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/presentation/screens/sign_in_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initSupabase();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: darkTheme(),
      home: UserService().isUserLogin?HomeScreen() : SignInScreen(),
    );
  }
}

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://fyfutnuahjknmvdorkwa.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ5ZnV0bnVhaGprbm12ZG9ya3dhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5MDY1MDgsImV4cCI6MjA3OTQ4MjUwOH0.QMY5rWu8kzSJdayLsnSiUQnQLkMNyimRImNvrDsBu30',
  );
}
