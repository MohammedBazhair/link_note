import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/features/network/connectivity_service.dart';
import '../../../../../core/presentation/providers/core_providers.dart';
import '../../../domain/repositories/sync_note_repository.dart';
import '../../../injection.dart';

class SyncNotesController extends Notifier<bool> {
  ConnectivityService get _network => ref.read(networkProvider);
  SyncNoteRepository get _syncNotesRepo =>
      ref.read(syncNotesRepositoryProvider);

  @override
  bool build() {
    final listen = _network.listenToConnectionChanges((status) async {
      final hasConnection = await _network.hasConnection();
      if (hasConnection) {
        await syncNotes();
      }
    });

    ref.onDispose(listen.cancel);
    return false;
  }

  Future<void> syncNotes() async {
    if (state) return;

    try {
      state = true;
      final userId = ref.read(userControllerProvider.notifier).currentUser?.id;
      await _syncNotesRepo.syncAllNotes(userId);
    } finally {
      state = false;
    }
  }
}
