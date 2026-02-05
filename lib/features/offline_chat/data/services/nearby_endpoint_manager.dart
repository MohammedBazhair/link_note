import '../models/nearby_identity_model.dart';
import 'nearby_connection_manager.dart';

/// Manages endpoint states and connections tracking
class NearbyEndpointManager {
  final IdentityMap _endpoints = {};
  final Set<String> _connectedEndpointIds = {};

  Iterable<String> get knownEndpointIds => _endpoints.keys;

  bool isConnected(String endpointId) =>
      _connectedEndpointIds.contains(endpointId);

  bool isUserIdConnected(String userId) {
    return _endpoints.entries.any(
      (e) => e.value.uuid == userId && _connectedEndpointIds.contains(e.key),
    );
  }

  void addEndpoint(String endpointId, NearbyIdentityModel identity) {
    // Check if we already have a CONNECTED session with this user UUID
    final activeId = _endpoints.entries
        .where(
          (e) =>
              e.value.uuid == identity.uuid &&
              _connectedEndpointIds.contains(e.key),
        )
        .map((e) => e.key)
        .firstOrNull;

    if (activeId != null && activeId != endpointId) {
      // Keep the active connection, ignore new discovery for same UUID
      return;
    }

    // Remove any existing disconnected entries for same UUID to prevent duplicates
    _endpoints.removeWhere(
      (id, existingIdentity) =>
          existingIdentity.uuid == identity.uuid && id != endpointId,
    );

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
