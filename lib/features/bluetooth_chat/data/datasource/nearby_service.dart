import 'dart:async';

import 'package:flutter/services.dart';
import 'package:nearby_connections/nearby_connections.dart';

import '../../../../core/constants/internal_constants/log.dart';
import '../models/incoming_frame.dart';

/// Manages Nearby advertising/discovery, connections, and payload I/O.
class NearbyConnectionManager {
  NearbyConnectionManager(this._adapter, this._localUserName);

  final Nearby _adapter;
  String _localUserName;

  void updateLocalUserName(String newName) {
    _localUserName = newName;
  }

  final Map<String, String> _endpointNames = {};
  final Set<String> _connectedEndpoints = {};

  final StreamController<IncomingFrame> _incomingController =
      StreamController<IncomingFrame>.broadcast();
  Stream<IncomingFrame> get incoming => _incomingController.stream;

  final StreamController<Map<String, String>> _discoveredController =
      StreamController<Map<String, String>>.broadcast();
  Stream<Map<String, String>> get discovered => _discoveredController.stream;

  final StreamController<Set<String>> _connectedController =
      StreamController<Set<String>>.broadcast();
  Stream<Set<String>> get connectedStream => _connectedController.stream;

  final StreamController<Map<String, String>> _allKnownController =
      StreamController<Map<String, String>>.broadcast();
  Stream<Map<String, String>> get allKnownEndpoints =>
      _allKnownController.stream;

  /// Helper to get all endpoints that we know about (discovered or connection info)
  Iterable<String> get discoveredEndpoints => _endpointNames.keys;

  bool _advertising = false;
  bool _discovering = false;

  bool get isAdvertising => _advertising;
  bool get isDiscovering => _discovering;

  /// Start advertising to allow others to discover and connect.
  Future<void> startAdvertising({
    required Strategy strategy,
    required String serviceId,
  }) async {
    if (_advertising) return;

    try {
      _advertising = await _adapter.startAdvertising(
        _localUserName,
        strategy,
        // عندما يطلب جهاز الاتصال
        onConnectionInitiated: (endpointId, connectionInfo) async {
          _endpointNames[endpointId] = connectionInfo.endpointName;
          _notifyKnown();
          await acceptConnection(endpointId);
        },
        // نتيجة محاولة الاتصال (نجاح/رفض/فشل).
        onConnectionResult: _onConnectionResult,
        //  عند انتهاء الاتصال
        onDisconnected: _onDisconnected,
        serviceId: serviceId,
      );
    } catch (e) {
      Logger.log(error: e);
      rethrow;
    }
  }

  Future<void> restartAdvertising({
    required Strategy strategy,
    required String serviceId,
  }) async {
    await stopAdvertising();
    await startAdvertising(strategy: strategy, serviceId: serviceId);
  }

  /// Start discovery to find nearby advertisers.
  Future<void> startDiscovery({
    required Strategy strategy,
    required String serviceId,
  }) async {
    if (_discovering) return;

    try {
      _discovering = await _adapter.startDiscovery(
        _localUserName,
        strategy,
        onEndpointFound: (endpointId, endpointName, serviceIdFound) {
          _endpointNames[endpointId] = endpointName;
          _notifyKnown();
        },
        onEndpointLost: (endpointId) {
          // We don't necessarily remove from _endpointNames here
          // because it might be a connected device that just stopped advertising.
          _notifyKnown();
        },
        serviceId: serviceId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> restartDiscovery({
    required Strategy strategy,
    required String serviceId,
  }) async {
    await stopDiscovery();
    // Only clear names for devices we are NOT currently connected to.
    _endpointNames.removeWhere((id, _) => !isConnected(id));
    _notifyKnown();
    await startDiscovery(strategy: strategy, serviceId: serviceId);
  }

  void _onPayLoadRecieved(String id, Payload payload) {
    if (payload.bytes == null) return;

    // HEAL STATE: If we got a payload, we must be connected
    if (!_connectedEndpoints.contains(id)) {
      _connectedEndpoints.add(id);
      _connectedController.add(Set.from(_connectedEndpoints));
      _notifyKnown();
    }

    switch (payload.type) {
      case PayloadType.BYTES:
      case PayloadType.FILE:
        _incomingController.add(
          IncomingFrame(
            peerEndpointId: id,
            bytes: Uint8List.fromList(payload.bytes!),
          ),
        );

      case PayloadType.NONE:
      case PayloadType.STREAM:
    }
  }

  Future<bool> acceptConnection(String endpointId) {
    return _adapter.acceptConnection(
      endpointId,
      onPayLoadRecieved: _onPayLoadRecieved,
      onPayloadTransferUpdate: (_, __) {},
    );
  }

  /// Connect to a discovered endpoint.
  Future<void> connect(String endpointId) async {
    if (isConnected(endpointId)) return;

    try {
      await _adapter.requestConnection(
        _localUserName,
        endpointId,
        onConnectionInitiated: (id, connectionInfo) async {
          _endpointNames[id] = connectionInfo.endpointName;
          _discoveredController.add(Map<String, String>.from(_endpointNames));
          await acceptConnection(id);
        },
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
    } catch (e) {
      if (e.toString().contains('already connected')) {
        // Heal state
        _connectedEndpoints.add(endpointId);
        _connectedController.add(Set.from(_connectedEndpoints));
        _notifyKnown();
        return;
      }
      rethrow;
    }
  }

  bool isConnected(String endpointId) =>
      _connectedEndpoints.contains(endpointId);

  String? endpointName(String endpointId) => _endpointNames[endpointId];

  Future<void> sendBytes(String endpointId, Uint8List bytes) async {
    try {
      if (!isConnected(endpointId)) {
        Logger.log(
          error: 'Attempt to send to disconnected endpoint $endpointId',
        );
        return;
      }

      await _adapter.sendBytesPayload(endpointId, bytes);
    } catch (e) {
      Logger.log(error: e);
    }
  }

  Future<void> sendFileBytes({
    required String endpointId,
    required String filePath,
  }) async {
    try {
      if (!isConnected(endpointId)) {
        Logger.log(
          error: 'Attempt to send to disconnected endpoint $endpointId',
        );
        return;
      }

      await _adapter.sendFilePayload(endpointId, filePath);
    } catch (e) {
      Logger.log(error: e);
    }
  }

  void _notifyKnown() {
    _discoveredController.add(Map<String, String>.from(_endpointNames));
    _allKnownController.add(Map<String, String>.from(_endpointNames));
  }

  /// Find an endpoint ID associated with a specific user UUID
  String? getEndpointIdByUserName(String userUuid) {
    for (var entry in _endpointNames.entries) {
      final identity = entry.value;
      final peerUuid = identity.split('|')[0];
      if (peerUuid == userUuid) return entry.key;
    }
    return null;
  }

  /// Get the display name of an endpoint (extracts from "UUID|Name" if needed)
  String getDisplayName(String endpointId) {
    final raw = _endpointNames[endpointId] ?? endpointId;
    final parts = raw.split('|');
    return parts.length > 1 ? parts[1] : parts[0];
  }

  void _onConnectionResult(String endpointId, Status status) {
    /// منطق نتيجة الاتصال هل مرفوضة ام مسموحة
    switch (status) {
      case Status.CONNECTED:
        _connectedEndpoints.add(endpointId);
        _connectedController.add(Set.from(_connectedEndpoints));

      case Status.REJECTED:
      case Status.ERROR:
        _connectedEndpoints.remove(endpointId);
        _endpointNames.remove(endpointId);
        _connectedController.add(Set.from(_connectedEndpoints));
        _notifyKnown();
    }
  }

  Future<void> _onDisconnected(String endpointId) async {
    await _adapter.disconnectFromEndpoint(endpointId);
    _connectedEndpoints.remove(endpointId);
    _endpointNames.remove(endpointId);
    _connectedController.add(Set.from(_connectedEndpoints));
    _notifyKnown();
  }

  Future<void> stopAll() async {
    if (_advertising) {
      await _adapter.stopAdvertising();
      _advertising = false;
    }
    if (_discovering) {
      await stopDiscovery();
    }
  }

  Future<void> stopAdvertising() async {
    await _adapter.stopAdvertising();
    _advertising = false;
  }

  Future<void> stopDiscovery() async {
    await _adapter.stopDiscovery();
    _discovering = false;
  }

  Future<void> disconnect(String endpointId) async {
    await _adapter.disconnectFromEndpoint(endpointId);
    _connectedEndpoints.remove(endpointId);
  }

  Future<void> dispose() async {
    await stopAll();
    await _incomingController.close();
    await _discoveredController.close();
    await _connectedController.close();
    await _allKnownController.close();
  }
}
