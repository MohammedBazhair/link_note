import 'dart:async';

import 'package:flutter/services.dart';
import 'package:nearby_connections/nearby_connections.dart';

import '../../../../core/constants/internal_constants/log.dart';
import '../../../../core/errors/result.dart';
import '../di_heplers.dart';
import '../models/incoming_frame.dart';
import '../models/nearby_identity_model.dart';

typedef IdentityMap = Map<String, NearbyIdentityModel>;

/// Handles Nearby Connections (advertising, discovery, connections, payloads)
class NearbyConnectionService {
  NearbyConnectionService(this._adapter, this._localIdentity);

  final Nearby _adapter;
  NearbyIdentityModel _localIdentity;

  NearbyIdentityModel get localIdentity => _localIdentity;

  final IdentityMap _endpoints = {};
  final Set<String> _connectedEndpointIds = {};
  final Map<int, String> _payloadPaths = {};

  final _incomingStreamController = StreamController<IncomingFrame>.broadcast();
  Stream<IncomingFrame> get incomingFrames => _incomingStreamController.stream;

  final _discoveredStreamController = StreamController<IdentityMap>.broadcast();
  Stream<IdentityMap> get discoveredEndpoints =>
      _discoveredStreamController.stream;

  final _connectedStreamController = StreamController<Set<String>>.broadcast();
  Stream<Set<String>> get connectedEndpointsStream =>
      _connectedStreamController.stream;

  final _allKnownStreamController = StreamController<IdentityMap>.broadcast();
  Stream<IdentityMap> get allKnownEndpoints => _allKnownStreamController.stream;

  Iterable<String> get knownEndpointIds => _endpoints.keys;

  void updateLocalName(String newName) {
    _localIdentity = _localIdentity.copyWith(displayName: newName);
  }

  void updateAvatar(Uint8List avatarBytes) {
    _localIdentity = _localIdentity.copyWith(avatarBytes: avatarBytes);
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

  Future<Result<bool>> initializeDependencies() async {
    if (!await requestNearbyPermissions()) {
      return Result.error('الصلاحيات غير كافية لتشغيل الشات القريب');
    }

    if (!await ensureLocationEnabled()) {
      return Result.error('يجب تفعيل الموقع لتشغيل الشات القريب');
    }

    if (!await ensureBluetoothEnabled()) {
      return Result.error('يجب تفعيل البلوتوث لتشغيل الشات القريب');
    }

    return Result.ok(true);
  }

  Future<bool> startAdvertising({
    required Strategy strategy,
    required String serviceId,
  }) {
    return _adapter.startAdvertising(
      _localIdentity.toJson(),
      strategy,
      serviceId: serviceId,
      // عندما يطلب جهاز الاتصال
      onConnectionInitiated: _handleIncomingConnection,
      // نتيجة محاولة الاتصال (نجاح/رفض/فشل).
      onConnectionResult: _handleConnectionResult,
      //  عند انتهاء الاتصال
      onDisconnected: _handleDisconnection,
    );
  }

  Future<bool> startDiscovery({
    required Strategy strategy,
    required String serviceId,
  }) {
    return _adapter.startDiscovery(
      _localIdentity.toJson(),
      strategy,
      serviceId: serviceId,
      onEndpointFound: _handleEndpointFound,

      onEndpointLost: _handleEndpointLost,
    );
  }

  Future<void> stopAdvertising() => _adapter.stopAdvertising();

  Future<void> stopDiscovery() => _adapter.stopDiscovery();

  Future<void> stopAll() async {
    await stopAdvertising();
    await stopDiscovery();
  }

  bool isConnected(String endpointId) =>
      _connectedEndpointIds.contains(endpointId);

  Future<void> connect(String endpointId) async {
    if (isConnected(endpointId)) return;

    // PRO TIP: On some devices, stopping discovery before connecting improves reliability.
    await stopDiscovery();

    // Give the radio a moment to stabilize
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      await _adapter.requestConnection(
        _localIdentity.toJson(),
        endpointId,
        onConnectionInitiated: _handleIncomingConnection,
        onConnectionResult: _handleConnectionResult,
        onDisconnected: _handleDisconnection,
      );
    } catch (e) {
      Logger.log(error: 'Connection error to $endpointId: $e');
      if (e.toString().contains('already connected')) {
        _markConnected(endpointId);
      }
    }
  }

  void _markConnected(String endpointId) {
    _connectedEndpointIds.add(endpointId);
    _connectedStreamController.add(Set.from(_connectedEndpointIds));
    _notifyKnownEndpoints();
  }

  Future<void> disconnect(String endpointId) async {
    await _adapter.disconnectFromEndpoint(endpointId);
    _connectedEndpointIds.remove(endpointId);
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

      return result.key;
    } on StateError catch (_) {
      return '...';
    }
  }

  Future<void> sendBytes(String endpointId, Uint8List bytes) async {
    if (!isConnected(endpointId)) return;

    await _adapter.sendBytesPayload(endpointId, bytes);
  }

  Future<int?> sendFile({
    required String endpointId,
    required String filePath,
  }) {
    if (!isConnected(endpointId)) return Future.value();

    return _adapter.sendFilePayload(endpointId, filePath);
  }

  void _handleIncomingConnection(String endpointId, ConnectionInfo info) async {
    final identity = NearbyIdentityModel.fromJson(info.endpointName);
    _endpoints[endpointId] = identity;
    _notifyKnownEndpoints();
    await acceptConnection(endpointId);
  }

  Future<bool> acceptConnection(String endpointId) {
    return _adapter.acceptConnection(
      endpointId,
      onPayLoadRecieved: _handlePayloadReceived,
      onPayloadTransferUpdate: _handlePayloadTransfer,
    );
  }

  void _handleConnectionResult(String endpointId, Status status) {
    switch (status) {
      case Status.CONNECTED:
        _markConnected(endpointId);

      case Status.REJECTED:
      case Status.ERROR:
        _removeEndpoint(endpointId);
    }
  }

  Future<void> _handleDisconnection(String endpointId) async {
    await _adapter.disconnectFromEndpoint(endpointId);

    _removeEndpoint(endpointId);
  }

  void _handleEndpointFound(
    String endpointId,
    String endpointName,
    String serviceId,
  ) {
    final identity = NearbyIdentityModel.fromJson(endpointName);
    _endpoints[endpointId] = identity;
    _notifyKnownEndpoints();
  }

  void _handleEndpointLost(String? endpointId) {
    if (endpointId != null) _removeEndpoint(endpointId);
  }

  void _handlePayloadReceived(String endpointId, Payload payload) {
    if (payload.type == PayloadType.BYTES && payload.bytes == null) return;

    // HEAL STATE: If we got a payload, we must be connected
    if (!_connectedEndpointIds.contains(endpointId)) {
      _markConnected(endpointId);
    }

    switch (payload.type) {
      case PayloadType.BYTES:
        _incomingStreamController.add(
          IncomingFrame(
            peerEndpointId: endpointId,
            payloadId: payload.id,
            bytes: payload.bytes,
          ),
        );
      case PayloadType.FILE:
        Logger.log(
          message:
              'FILE payload received: ${payload.id} path: ${payload.filePath}',
        );
        if (payload.filePath != null) {
          _payloadPaths[payload.id] = payload.filePath!;
        }
      case PayloadType.NONE:
      case PayloadType.STREAM:
    }
  }

  void _handlePayloadTransfer(String endpointId, PayloadTransferUpdate update) {
    switch (update.status) {
      case PayloadStatus.IN_PROGRESS:
        break;
      case PayloadStatus.SUCCESS:
        final path = _payloadPaths.remove(update.id);

        _incomingStreamController.add(
          IncomingFrame(
            peerEndpointId: endpointId,
            payloadId: update.id,
            filePath: path,
          ),
        );

      case PayloadStatus.FAILURE:
      case PayloadStatus.CANCELED:
        _payloadPaths.remove(update.id);

      case PayloadStatus.NONE:
    }
  }

  void _removeEndpoint(String endpointId) {
    _connectedEndpointIds.remove(endpointId);
    _endpoints.remove(endpointId);
    _connectedStreamController.add(Set.from(_connectedEndpointIds));
    _notifyKnownEndpoints();
  }

  void _notifyKnownEndpoints() {
    final copy = IdentityMap.from(_endpoints);
    _discoveredStreamController.add(copy);
    _allKnownStreamController.add(Map.from(_endpoints));
  }

  Future<void> dispose() async {
    await stopAll();
    await _incomingStreamController.close();
    await _discoveredStreamController.close();
    await _connectedStreamController.close();
    await _allKnownStreamController.close();
  }
}
