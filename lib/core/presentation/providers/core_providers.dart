import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/network/connectivity_service.dart';

final networkProvider = Provider((_) {
  return GetIt.I<ConnectivityService>();
});

final supabaseProvider = Provider((ref) {
  return GetIt.I<GoTrueClient>();
});

final tokenRefreshProvider = Provider((ref) {
  final network = ref.watch(networkProvider);
  final supabase = ref.watch(supabaseProvider);
  // استمع لتغييرات الاتصال
  final subscription = network.listenToConnectionChanges((status) async {
    if (status == InternetStatus.connected) {
      try {
        // جدد التوكن فقط عند الاتصال الأول
        final session = supabase.currentSession;
        if (session == null || session.isExpired) {
          await supabase.refreshSession();
        }
      } catch (e) {
        debugPrint('Failed to refresh token: $e');
      }
    }
  });

  ref.onDispose(subscription.cancel);
});
