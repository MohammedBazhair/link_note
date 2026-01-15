import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_controller.dart';

final sessionMembersStreamProvider = StreamProvider.autoDispose((ref) {
  final sessionController = ref.read(sessionControllerProvider.notifier);

  return sessionController.fetchMembersOfSession();
});

final sessionProvider = Provider.autoDispose((ref) {
  return ref.watch(sessionControllerProvider).session;
});
