import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/features/injection.dart';
import 'core/presentation/screens/auth_gate.dart';
import 'core/theme/dark_theme.dart';
import 'features/auth/injection.dart';
import 'features/note/injection.dart';
import 'features/user/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initSupabase();
  await setupLocators();


  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: darkTheme(),
      home: const AuthGate(),
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

Future<void> setupLocators() async {
  await setupCommonDependincies();
  setupAuthDependincies();
  setupNotesDependincies();
  setupUserDependincies();
}
