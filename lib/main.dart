import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/external_constants/external_constants.dart';
import 'core/features/common_injections.dart';
import 'core/presentation/screens/auth_gate.dart';
import 'core/theme/dark_theme.dart';
import 'features/auth/injection.dart';
import 'features/note/injection.dart';
import 'features/session/injection.dart';
import 'features/user/injection.dart';


void main() async {
  await _setupApp();
  runApp(const ProviderScope(child: MainApp()));
}

Future<void> _setupApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  _initLocalDatabase();
  await _registerMyAppProtocol();
  await _initSupabase();
  await _setupLocators();
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

void _initLocalDatabase() {
  if (!Platform.isWindows) return;
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

Future<void> _registerMyAppProtocol() async {
  if (Platform.isWindows) await protocolHandler.register('linknote');
}

Future<void> _initSupabase() async {
  await Supabase.initialize(
    url: ExternalConsts.supabaseUrl,
    anonKey: ExternalConsts.supabaseAnonKey,
  );
}

Future<void> _setupLocators() async {
  await setupCommonDependincies();
  setupAuthDependincies();
  setupNotesDependincies();
  setupUserDependincies();
  setupSessionsDependincies();
}
