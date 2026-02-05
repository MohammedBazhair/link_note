import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_connections/nearby_connections.dart';

import '../../../../core/constants/internal_constants/log.dart';
import '../../../../core/errors/exceptions.dart';
import '../../data/services/nearby_connection_manager.dart';
import '../../domain/entities/nearby_identity.dart';
import 'nearby_providers.dart';
import 'nearby_state.dart';

/// Controller to manage Nearby Connections discovery and advertising.
class NearbyDiscoveryController extends Notifier<NearbyState> {
  late final NearbyConnectionManager _nearbyManager;

  Stream<Map<String, NearbyIdentity>> get endpoints =>
      _nearbyManager.allKnownEndpoints;

  @override
  NearbyState build() {
    _nearbyManager = ref.read(nearbyConnectionManagerProvider);

    ref.onDispose(stopAll);

    return NearbyInitialState(nearby: const NearbyData());
  }

  Future<void> runDependencies() async {
    final result = await _nearbyManager.initializeDependencies();

    if (!result.hasError) return;

    state = NearbyeErrorState(
      nearby: state.nearby,
      message: result.errorMessage!,
    );
  }

  Future<void> beginNearbyCommunication({
    required Strategy strategy,
    required String serviceId,
  }) async {
    try {
      await startAdvertising(strategy: strategy, serviceId: serviceId);

      final isDiscovering = await startDiscovery(
        strategy: strategy,
        serviceId: serviceId,
      );

      Future.delayed(const Duration(seconds: 7), () async {
        if (!isDiscovering) return;

        await stopDiscovery();
        state = NearbyUpdatedState(
          nearby: state.nearby.copyWith(isDiscovering: false),
        );
      });
    } catch (e) {
      Logger.log(error: e);
      state = NearbyeErrorState(nearby: state.nearby, message: e.toString());
    }
  }

  Future<bool> startDiscovery({
    required Strategy strategy,
    required String serviceId,
  }) async {
    try {
      if (state.nearby.isDiscovering) {
        throw const AlreadyRunnedException('أنت حاليا يمكن للجميع رؤيتك');
      }
      final isDiscovering = await _nearbyManager.startDiscovery(
        strategy: strategy,
        serviceId: serviceId,
      );
      if (!isDiscovering) return false;

      state = NearbyUpdatedState(
        nearby: state.nearby.copyWith(isDiscovering: true),
      );
      return true;
    } on AlreadyRunnedException catch (e) {
      state = NearbyeErrorState(nearby: state.nearby, message: e.message);
      return true;
    } catch (e) {
      state = NearbyeErrorState(nearby: state.nearby, message: e.toString());
      return state.nearby.isDiscovering;
    }
  }

  Future<bool> startAdvertising({
    required Strategy strategy,
    required String serviceId,
  }) async {
    try {
      if (state.nearby.isAdvertising) {
        throw const AlreadyRunnedException('أنت حاليا يمكن للجميع رؤيتك');
      }
      final isAdvertising = await _nearbyManager.startAdvertising(
        strategy: strategy,
        serviceId: serviceId,
      );
      if (!isAdvertising) return false;

      state = NearbyUpdatedState(
        nearby: state.nearby.copyWith(isAdvertising: true),
      );
      return true;
    } on AlreadyRunnedException catch (_) {
      return true;
    } catch (e) {
      state = NearbyeErrorState(nearby: state.nearby, message: e.toString());

      return state.nearby.isAdvertising;
    }
  }

  /// Stop discovery and advertising, clean up resources.
  Future<void> stopAll() async {
    await stopDiscovery();
    await stopAdvertising();
  }

  Future<void> stopAdvertising() async {
    try {
      await _nearbyManager.stopAdvertising();
      state = NearbyUpdatedState(
        nearby: state.nearby.copyWith(isAdvertising: false),
      );
    } catch (e) {
      Logger.log(error: e);
    }
  }

  Future<void> stopDiscovery() async {
    try {
      await _nearbyManager.stopDiscovery();
      state = NearbyUpdatedState(
        nearby: state.nearby.copyWith(isDiscovering: false),
      );
    } catch (e) {
      Logger.log(error: e);
    }
  }

  Future<void> restartNearbyCommunication({
    required Strategy strategy,
    required String serviceId,
  }) async {
    try {
      await stopAll();
      // Give the radio a full second to reset
      await Future.delayed(const Duration(seconds: 1));
      await beginNearbyCommunication(strategy: strategy, serviceId: serviceId);
    } catch (e) {
      Logger.log(error: e);
    }
  }
}
