import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_connections/nearby_connections.dart';

import '../../../../core/presentation/providers/core_providers.dart';
import '../../../user/presentation/controllers/user_providers.dart';
import '../../data/models/incoming_frame.dart';
import '../../data/models/nearby_identity_model.dart';
import '../../data/services/nearby_connection_manager.dart';
import '../../data/services/nearby_endpoint_manager.dart';
import '../../data/services/nearby_identity_manager.dart';
import '../../data/services/nearby_streams_notifier.dart';
import '../../data/services/payload_handler.dart';

final nearbyProvider = Provider<Nearby>((ref) {
  final raw = Nearby();
  return raw;
});

final nearbyIdentityManagerProvider = Provider<NearbyIdentityManager>((ref) {
  final profile = ref.watch(userControllerProvider).profile;
  final cache = ref.read(memoryCacheProvider);
  final model = NearbyIdentityModel(
    uuid: profile.userId,
    displayName: profile.username,
  );
  cache.set('profileJson', model.toJson());
  final manager = NearbyIdentityManager(model, cache);

  if (profile.avatarUrl != null) {
    final asyncFile = ref.read((getAvatarFileProvider(profile.avatarUrl!)));
    asyncFile.whenData((file) async {
      final bytes = await file.readAsBytes();
      manager.updateAvatar(bytes);
      cache.set('profileJson', manager.localIdentityJson);
    });
  }

  return manager;
});

final nearbyEndpointManagerProvider = Provider<NearbyEndpointManager>(
  (ref) => NearbyEndpointManager(),
);

final nearbyPayloadManagerProvider = Provider<NearbyPayloadManager>(
  (ref) => NearbyPayloadManager(),
);

final nearbyStreamNotifierProvider = Provider<NearbyStreamNotifier>(
  (ref) => NearbyStreamNotifier(),
);

final nearbyConnectionManagerProvider =
    Provider.autoDispose<NearbyConnectionManager>((ref) {
      final adapter = ref.read(nearbyProvider);
      final identity = ref.read(nearbyIdentityManagerProvider);
      final endpoint = ref.read(nearbyEndpointManagerProvider);
      final payload = ref.read(nearbyPayloadManagerProvider);
      final notifier = ref.read(nearbyStreamNotifierProvider);

      final service = NearbyConnectionManager(
        adapter,
        identity,
        endpoint,
        payload,
        notifier,
      );

      ref.onDispose(service.dispose);

      return service;
    });

final incomingFramesProvider = StreamProvider<IncomingFrame>((ref) async* {
  final manager = ref.watch(nearbyConnectionManagerProvider);
  yield* manager.incomingFrames;
});

final discoveredEndpointsProvider = StreamProvider<IdentityMap>((ref) async* {
  final manager = ref.watch(nearbyConnectionManagerProvider);
  yield* manager.discoveredEndpoints;
});

final connectedEndpointsProvider = StreamProvider<Set<String>>((ref) async* {
  final manager = ref.watch(nearbyConnectionManagerProvider);
  yield* manager.connectedEndpointsStream;
});

final allKnownEndpointsProvider = StreamProvider<IdentityMap>((ref) async* {
  final manager = ref.watch(nearbyConnectionManagerProvider);
  yield* manager.allKnownEndpoints;
});

final isPeerConnectedProvider = Provider.family<bool, String>((ref, peerId) {
  // Watch only for changes in the connected endpoints stream
  ref.watch(connectedEndpointsProvider);
  final manager = ref.read(nearbyConnectionManagerProvider);
  return manager.isUserIdConnected(peerId);
});
