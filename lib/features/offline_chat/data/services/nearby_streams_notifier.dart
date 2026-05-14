import 'dart:async';

import 'nearby_connection_manager.dart';

/// Manages stream notifications for discovered and connected endpoints
class NearbyStreamNotifier {
  final _discoveredStreamController = StreamController<IdentityMap>.broadcast();
  Stream<IdentityMap> get discoveredEndpoints =>
      _discoveredStreamController.stream;

  final _connectedStreamController = StreamController<Set<String>>.broadcast();
  Stream<Set<String>> get connectedEndpointsStream =>
      _connectedStreamController.stream;

  final _allKnownStreamController = StreamController<IdentityMap>.broadcast();
  Stream<IdentityMap> get allKnownEndpoints => _allKnownStreamController.stream;

  void notifyDiscoveredEndpoints(IdentityMap endpoints) {
    _discoveredStreamController.add(endpoints);
  }

  void notifyConnectedEndpoints(Set<String> connectedIds) {
    _connectedStreamController.add(connectedIds);
  }

  void notifyAllKnownEndpoints(IdentityMap endpoints) {
    _allKnownStreamController.add(Map.from(endpoints));
  }

  Future<void> dispose() async {
    await _discoveredStreamController.close();
    await _connectedStreamController.close();
    await _allKnownStreamController.close();
  }
}
