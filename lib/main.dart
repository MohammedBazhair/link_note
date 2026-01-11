import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/external_constants/external_constants.dart';
import 'core/features/common_injections.dart';
import 'core/presentation/screens/main_app.dart';
import 'features/auth/injection.dart';
import 'features/note/injection.dart';
import 'features/session/injection.dart';
import 'features/user/injection.dart';
import 'firebase_options.dart';

void main() async {
  await _setupApp();
  runApp(const ProviderScope(child: MainApp()));
}

Future<void> _setupApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _initLocalDatabase();
  await _registerMyAppProtocol();
  await _initSupabase();
  await _setupLocators();
  await setupOneSignal();
}

Future<void> setupOneSignal() async {
  // Enable verbose logging for debugging (remove in production)
  await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // Initialize with your OneSignal App ID
  OneSignal.initialize('77e0bc45-9e18-491e-bc41-0d42d7b86c00');
  // Use this method to prompt for push notifications.
  // We recommend removing this method after testing and instead use In-App Messages to prompt for notification permission.
  await OneSignal.Notifications.requestPermission(true);
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
