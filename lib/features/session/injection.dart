import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/presentation/providers/core_providers.dart';
import 'data/repository/session_repository_impl.dart';
import 'presentation/controllers/session_controller.dart';

final sessionRepositoryProvider = Provider((ref) {
  final remote = ref.read(remoteDatabaseServiceProvider);

  return SessionRepositoryImpl(remote);
});

final sessionControllerProvider = NotifierProvider(SessionController.new);
