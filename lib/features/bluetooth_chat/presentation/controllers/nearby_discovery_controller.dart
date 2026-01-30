import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_connections/nearby_connections.dart';

import '../../../../core/constants/internal_constants/log.dart';
import '../../data/datasource/nearby_service.dart';
import 'chat_providers.dart';

/// Controller to manage Nearby Connections discovery and advertising.
class NearbyDiscoveryController extends Notifier<void> {
  late final NearbyConnectionManager _nearbyManager;

  @override
  void build() {
    _nearbyManager = ref.read(connectionManagerProvider);

    ref.onDispose(stopAll);
  }

  Future<void> beginNearbyCommunication({
    required Strategy strategy,
    required String serviceId,
  }) async {
    try {
      await _nearbyManager.startAdvertising(
        strategy: strategy,
        serviceId: serviceId,
      );

      await _nearbyManager.startDiscovery(
        strategy: strategy,
        serviceId: serviceId,
      );
    } catch (e, st) {
      Logger.log(error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> startDiscovery({
    required Strategy strategy,
    required String serviceId,
  }) async {
    await _nearbyManager.startDiscovery(
      strategy: strategy,
      serviceId: serviceId,
    );
  }

  Future<void> startAdvertising({
    required Strategy strategy,
    required String serviceId,
  }) async {
    await _nearbyManager.startAdvertising(
      strategy: strategy,
      serviceId: serviceId,
    );
  }

  /// Stop discovery and advertising, clean up resources.
  Future<void> stopAll() async {
    print('Stop All.');
    await _nearbyManager.stopDiscovery();
    await _nearbyManager.stopAdvertising();
    print('Stop discovery and advertising, clean up resources.');
  }

  Future<void> restartNearbyCommunication({
    required Strategy strategy,
    required String serviceId,
  }) async {
    await stopAll();
    await beginNearbyCommunication(strategy: strategy, serviceId: serviceId);
  }
}
