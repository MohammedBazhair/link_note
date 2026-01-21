import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../core/presentation/providers/core_providers.dart';
import 'data/repository/session_repository_impl.dart';
import 'presentation/controllers/session_controller.dart';
import 'presentation/controllers/session_state.dart';

final sessionRepositoryProvider = Provider((ref) {
  final remote = ref.read(remoteDatabaseServiceProvider);

  return SessionRepositoryImpl(remote);
});

final _sessionControllerProvider = Provider((ref) {
  final repo = ref.read(sessionRepositoryProvider);

  return SessionController(repo);
});

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
      final controller = ref.read(_sessionControllerProvider);
      return controller;
    });
