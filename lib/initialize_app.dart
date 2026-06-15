import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/external_constants/external_constants.dart';

Future<void> initializeApp() async {
  initializeDesktopDatabase();
  await registerAppProtocol();
  await initializeSupabase();
  await initializePushNotifications();
  await storagePermission();
}

Future<void> initializePushNotifications() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // OneSignal does not support desktop platforms
    return;
  }
  // Enable verbose logging for debugging (remove in production)
   await OneSignal.Debug.setLogLevel(kDebugMode ? OSLogLevel.verbose:OSLogLevel.none);
  // Initialize with your OneSignal App ID
  await OneSignal.initialize('77e0bc45-9e18-491e-bc41-0d42d7b86c00');
  await OneSignal.Notifications.requestPermission(true);
}

void initializeDesktopDatabase() {
  if (!Platform.isWindows) return;
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

Future<void> registerAppProtocol() async {
  if (Platform.isWindows) await protocolHandler.register('linknote');
}

Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: ExternalConsts.supabaseUrl,
    anonKey: ExternalConsts.supabaseAnonKey,
  );
}

Future<void> storagePermission() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    return;
  }
  await Permission.storage.request();
}
