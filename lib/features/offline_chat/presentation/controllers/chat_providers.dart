import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_connections/nearby_connections.dart';

import '../../../../core/presentation/providers/core_providers.dart';
import '../../data/datasource/nearby_service.dart';
import '../../data/models/nearby_identity_model.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/entities/message.dart';
import 'chat_controller.dart';
import 'nearby_discovery_controller.dart';
import 'nearby_state.dart';

final chatControllerProvider = NotifierProvider<ChatController, List<Message>>(
  () {
    return ChatController();
  },
);

class NearbyDisplayName extends Notifier<String> {
  @override
  String build() {
    final profile = ref.watch(userControllerProvider).profile;
    return profile.username;
  }

  void update(String name) => state = name;
}

final nearbyDisplayNameProvider = NotifierProvider<NearbyDisplayName, String>(
  NearbyDisplayName.new,
);

/// Low-level Nearby adapter + connection manager (Android only).
final nearbyProvider = Provider<Nearby>((ref) {
  final raw = Nearby();
  return raw;
});

final connectionManagerProvider = Provider.autoDispose<NearbyConnectionManager>(
  (ref) {
    final adapter = ref.watch(nearbyProvider);
    final displayName = ref.watch(nearbyDisplayNameProvider);
    final userRepo = ref.watch(userRepositoryProvider);
    final currentUser = userRepo.currentUser;

    // We encode identity as JSON to ensure stable data handling
    final identity = NearbyIdentityModel(
      uuid: currentUser?.id ?? 'unknown',
      displayName: displayName,
    );

    final manager = NearbyConnectionManager(adapter, identity);

    ref.onDispose(manager.dispose);
    return manager;
  },
);

final nearbyDiscoveryControllerProvider =
    NotifierProvider<NearbyDiscoveryController, NearbyState>(() {
      return NearbyDiscoveryController();
    });

final nearbyEndpointsProvider = StreamProvider<Map<String, String>>((ref) {
  final manager = ref.watch(connectionManagerProvider);
  return manager.allKnownEndpoints;
});

final nearbyConnectedEndpointsProvider = StreamProvider<Set<String>>((ref) {
  final manager = ref.watch(connectionManagerProvider);
  return manager.connectedStream;
});

final chatRepository = Provider((ref) {
  final connectionManager = ref.watch(connectionManagerProvider);
  final userRepo = ref.watch(userRepositoryProvider);
  final currentUser = userRepo.currentUser;

  if (currentUser == null) {
    throw Exception('User must be logged in for chat');
  }

  final sessionManager = ref.read(chatSessionManagerProvider);

  final displayName = ref.watch(nearbyDisplayNameProvider);

  final repo = ChatRepositoryImpl(
    connectionManager,
    sessionManager,
    myUserId: currentUser.id,
    myDisplayName: displayName,
  );
  ref.onDispose(repo.dispose);

  return repo;
});

final chatSessionManagerProvider = Provider((_) {
  return ChatSessionManager();
});
//
