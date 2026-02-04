import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_connections/nearby_connections.dart';

import '../../../../core/presentation/providers/core_providers.dart';
import '../../../user/presentation/controllers/user_providers.dart';
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

final connectionManagerProvider = Provider.autoDispose<NearbyConnectionService>(
  (ref) {
    final adapter = ref.watch(nearbyProvider);
    final displayName = ref.watch(nearbyDisplayNameProvider);

    final profile = ref.watch(userControllerProvider).profile;

    final identity = NearbyIdentityModel(
      uuid: profile.userId,
      displayName: displayName,
    );

    final manager = NearbyConnectionService(adapter, identity);

    if (profile.avatarUrl != null) {
      final asyncFile = ref.read((getAvatarFileProvider(profile.avatarUrl!)));
      asyncFile.whenData((file) async {
        final bytes = await file.readAsBytes();
        manager.updateAvatar(bytes);
      });
    }

    ref.onDispose(manager.dispose);
    return manager;
  },
);

final nearbyDiscoveryControllerProvider =
    NotifierProvider<NearbyDiscoveryController, NearbyState>(() {
      return NearbyDiscoveryController();
    });

final nearbyEndpointsProvider =
    StreamProvider<Map<String, NearbyIdentityModel>>((ref) {
      final manager = ref.watch(connectionManagerProvider);
      return manager.allKnownEndpoints;
    });

final nearbyConnectedEndpointsProvider = StreamProvider<Set<String>>((ref) {
  final manager = ref.watch(connectionManagerProvider);
  return manager.connectedEndpointsStream;
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
