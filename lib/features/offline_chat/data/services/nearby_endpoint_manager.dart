import '../models/nearby_identity_model.dart';
import 'nearby_connection_manager.dart';

/// Manages endpoint states and connections tracking
class NearbyEndpointManager {
  final IdentityMap _endpoints = {};
  final Set<String> _connectedEndpointIds = {};

  Iterable<String> get knownEndpointIds => _endpoints.keys;

  bool isConnected(String endpointId) =>
      _connectedEndpointIds.contains(endpointId);

  void addEndpoint(String endpointId, NearbyIdentityModel identity) {
    _endpoints[endpointId] = identity;
  }

  void removeEndpoint(String endpointId) {
    _connectedEndpointIds.remove(endpointId);
    _endpoints.remove(endpointId);
  }

  void markConnected(String endpointId) {
    _connectedEndpointIds.add(endpointId);
  }

  void markDisconnected(String endpointId) {
    _connectedEndpointIds.remove(endpointId);
  }

  void updateUuidMapping({required String uuid, required String name}) {
    for (final element in _endpoints.entries) {
      if (element.value.uuid == uuid) {
        _endpoints.update(
          element.key,
          (identity) => identity.copyWith(displayName: name),
        );
        return;
      }
    }
  }

  String? getEndpointIdByUserId(String userUuid) {
    try {
      final result = _endpoints.entries.firstWhere(
        (e) => e.value.uuid == userUuid,
      );

      return result.key;
    } on StateError catch (_) {
      return null;
    }
  }

  String getDisplayNameByEndpoint(String endpointId) {
    final identity = _endpoints[endpointId];

    return identity?.displayName ?? 'غير معروف';
  }

  String getDisplayNameByUserId(String userId) {
    try {
      final result = _endpoints.entries.firstWhere(
        (e) => e.value.uuid == userId,
      );

      return result.value.displayName;
    } on StateError catch (_) {
      return '...';
    }
  }

  IdentityMap getEndpointsCopy() => IdentityMap.from(_endpoints);
  Set<String> getConnectedEndpointsCopy() => Set.from(_connectedEndpointIds);
}
