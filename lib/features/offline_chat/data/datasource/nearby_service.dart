import 'dart:async';

import 'package:flutter/services.dart';
import 'package:nearby_connections/nearby_connections.dart';

import '../../../../core/constants/internal_constants/log.dart';
import '../../../../core/errors/result.dart';
import '../di_heplers.dart';
import '../models/incoming_frame.dart';
import '../models/nearby_identity_model.dart';

/// Manages Nearby advertising/discovery, connections, and payload I/O.
class NearbyConnectionManager {
  NearbyConnectionManager(this._adapter, this._currentIdentity);

  final Nearby _adapter;
  NearbyIdentityModel _currentIdentity;

  void updateLocalUserName(String newName) {
    _currentIdentity = _currentIdentity.copyWith(displayName: newName);
  }

  final Map<String, String> _endpointNames = {};
  final Map<String, String> _uuidToName = {};
  final Map<int, String> _payloadPaths = {};
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

   Future<Result<bool>> runDependencies() async {
    final isPermissionGranted = await requestNearbyPermissions();

    if (!isPermissionGranted) {
      return Result.error('الصلاحيات غير كافية لتشغيل الشات القريب');
    }

    final isLocationEnabled = await ensureLocationEnabled();

    if (!isLocationEnabled) {
      return Result.error('يجب تفعيل الموقع لتشغيل الشات القريب');
    }

    final isBluetoothEnabled = await ensureBluetoothEnabled();

    if (!isBluetoothEnabled) {
      return Result.error('يجب تفعيل البلوتوث لتشغيل الشات القريب');
    }

    return Result.ok(true);
  }

  /// Start advertising to allow others to discover and connect.
  Future<bool> startAdvertising({
    required Strategy strategy,
    required String serviceId,
  }) async {
    try {
      return await _adapter.startAdvertising(
        _currentIdentity.toJson(),
        strategy,
        // عندما يطلب جهاز الاتصال
        onConnectionInitiated: (endpointId, connectionInfo) async {
          _endpointNames[endpointId] = connectionInfo.endpointName;
          updateUuidFromIdentity(connectionInfo.endpointName);
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

  /// Start discovery to find nearby advertisers.
  Future<bool> startDiscovery({
    required Strategy strategy,
    required String serviceId,
  }) async {
    try {
      return await _adapter.startDiscovery(
        _currentIdentity.toJson(),
        strategy,
        onEndpointFound: (endpointId, endpointName, serviceIdFound) {
          _endpointNames[endpointId] = endpointName;
          updateUuidFromIdentity(endpointName);
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

  void _onPayLoadRecieved(String id, Payload payload) {
    if (payload.type == PayloadType.BYTES && payload.bytes == null) return;

    // HEAL STATE: If we got a payload, we must be connected
    if (!_connectedEndpoints.contains(id)) {
      _connectedEndpoints.add(id);
      _connectedController.add(Set.from(_connectedEndpoints));
      _notifyKnown();
    }

    switch (payload.type) {
      case PayloadType.BYTES:
        Logger.log(message: 'BYTES payload received: ${payload.id}');
        _incomingController.add(
          IncomingFrame(
            peerEndpointId: id,
            payloadId: payload.id,
            bytes: payload.bytes,
          ),
        );
        break;
      case PayloadType.FILE:
        Logger.log(
          message:
              'FILE payload received: ${payload.id} path: ${payload.filePath}',
        );
        if (payload.filePath != null) {
          _payloadPaths[payload.id] = payload.filePath!;
        } else {
          Logger.log(
            error: 'FILE payload has null filePath! id: ${payload.id}',
          );
        }
        break;
      case PayloadType.NONE:
      case PayloadType.STREAM:
        break;
    }
  }

  void _onPayloadTransferUpdate(
    String endpointId,
    PayloadTransferUpdate update,
  ) {
    switch (update.status) {
      case PayloadStatus.SUCCESS:
        final path = _payloadPaths.remove(update.id);
        Logger.log(
          message: 'Payload transfer SUCCESS: ${update.id} path: $path',
        );

        Logger.log(message: 'bytesTransferred: ${update.bytesTransferred}');
        Logger.log(message: 'total bytes: ${update.totalBytes}');
        _incomingController.add(
          IncomingFrame(
            peerEndpointId: endpointId,
            payloadId: update.id,
            filePath: path,
          ),
        );
        break;

      case PayloadStatus.IN_PROGRESS:
        break;
      case PayloadStatus.FAILURE:
      case PayloadStatus.CANCELED:
        Logger.log(
          message:
              'Payload transfer ${update.status.name.toUpperCase()}: ${update.id}',
        );
        _payloadPaths.remove(update.id);
        break;

      case PayloadStatus.NONE:
        break;
    }
  }

  Future<bool> acceptConnection(String endpointId) {
    return _adapter.acceptConnection(
      endpointId,
      onPayLoadRecieved: _onPayLoadRecieved,
      onPayloadTransferUpdate: _onPayloadTransferUpdate,
    );
  }

  /// Connect to a discovered endpoint.
  Future<void> connect(String endpointId) async {
    if (isConnected(endpointId)) return;

    Logger.log(
      message:
          'Requesting connection to $endpointId (Identity: $_currentIdentity)',
    );

    try {
      // PRO TIP: On some devices, stopping discovery before connecting improves reliability.
      await stopDiscovery();
      // Give the radio a moment to stabilize
      await Future.delayed(const Duration(milliseconds: 500));

      await _adapter.requestConnection(
        _currentIdentity.toJson(),
        endpointId,
        onConnectionInitiated: (id, connectionInfo) async {
          Logger.log(message: 'Connection initiated with $id');
          _endpointNames[id] = connectionInfo.endpointName;
          updateUuidFromIdentity(connectionInfo.endpointName);
          _discoveredController.add(Map<String, String>.from(_endpointNames));
          await acceptConnection(id);
        },
        onConnectionResult: (id, status) {
          Logger.log(message: 'Connection result for $id: ${status.name}');
          _onConnectionResult(id, status);
        },
        onDisconnected: (id) {
          Logger.log(message: 'Disconnected from $id');
          _onDisconnected(id);
        },
      );
    } catch (e) {
      Logger.log(error: 'Connection error to $endpointId: $e');
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

  Future<int?> sendFileBytes({
    required String endpointId,
    required String filePath,
  }) async {
    try {
      if (!isConnected(endpointId)) {
        Logger.log(
          error: 'Attempt to send to disconnected endpoint $endpointId',
        );
        return null;
      }

      return await _adapter.sendFilePayload(endpointId, filePath);
    } catch (e) {
      Logger.log(error: e);
      return null;
    }
  }

  void _notifyKnown() {
    _discoveredController.add(Map<String, String>.from(_endpointNames));
    _allKnownController.add(Map<String, String>.from(_endpointNames));
  }

  void updateUuidFromIdentity(String identity) {
    final model = NearbyIdentityModel.fromJson(identity);
    _uuidToName[model.uuid] = model.displayName;
  }

  void updateUuidMapping({required String uuid, required String name}) {
    _uuidToName[uuid] = name;
  }

  /// Find an endpoint ID associated with a specific user UUID
  String? getEndpointIdByUserName(String userUuid) {
    for (var entry in _endpointNames.entries) {
      final identity = entry.value;
      final model = NearbyIdentityModel.fromJson(identity);
      if (model.uuid == userUuid) return entry.key;
    }
    return null;
  }

  /// Get the display name of an endpoint (extracts from "UUID|Name" if needed)
  String getDisplayName(String endpointId) {
    final raw = _endpointNames[endpointId];
    if (raw != null) {
      final model = NearbyIdentityModel.fromJson(raw);
      return model.displayName;
    }
    // Fallback to searching by UUID if the input looks like one
    return _uuidToName[endpointId] ?? endpointId;
  }

  String getDisplayNameByUuid(String uuid) {
    return _uuidToName[uuid] ?? 'دردشة';
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
    await _adapter.stopAdvertising();
    await _adapter.stopDiscovery();
  }

  Future<void> stopAdvertising() async {
    await _adapter.stopAdvertising();
  }

  Future<void> stopDiscovery() async {
    await _adapter.stopDiscovery();
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
