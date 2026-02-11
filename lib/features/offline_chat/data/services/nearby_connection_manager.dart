import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:nearby_connections/nearby_connections.dart';

import '../../../../core/constants/internal_constants/log.dart';
import '../../../../core/errors/result.dart';
import '../di_heplers.dart';
import '../models/incoming_frame.dart';
import '../models/nearby_identity_model.dart';
import 'nearby_endpoint_manager.dart';
import 'nearby_identity_manager.dart';
import 'nearby_streams_notifier.dart';
import 'payload_handler.dart';

typedef IdentityMap = Map<String, NearbyIdentityModel>;

/// Main service orchestrating all nearby connection operations
class NearbyConnectionManager {
  NearbyConnectionManager(
    this._adapter,
    this._identityManager,
    this._endpointManager,
    this._payloadManager,
    this._streamNotifier,
  );

  final Nearby _adapter;
  final NearbyIdentityManager _identityManager;
  final NearbyEndpointManager _endpointManager;
  final NearbyPayloadManager _payloadManager;
  final NearbyStreamNotifier _streamNotifier;

  NearbyIdentityModel get localIdentity => _identityManager.localIdentity;

  Stream<IncomingFrame> get incomingFrames => _payloadManager.incomingFrames;

  Stream<IdentityMap> get discoveredEndpoints =>
      _streamNotifier.discoveredEndpoints;

  Stream<Set<String>> get connectedEndpointsStream =>
      _streamNotifier.connectedEndpointsStream;

  Stream<IdentityMap> get allKnownEndpoints =>
      _streamNotifier.allKnownEndpoints;

  Iterable<String> get knownEndpointIds => _endpointManager.knownEndpointIds;

  void updateAvatar(Uint8List avatarBytes) {
    _identityManager.updateAvatar(avatarBytes);
  }

  void updateIdentity(NearbyIdentityModel identity) {
    _endpointManager.updateIdentity(identity);
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
    final identity = _identityManager.localIdentityJson;
    return _adapter.startAdvertising(
      identity,
      strategy,
      serviceId: serviceId,
      onConnectionInitiated: _handleIncomingConnection,
      onConnectionResult: _handleConnectionResult,
      onDisconnected: _handleDisconnection,
    );
  }

  Future<bool> startDiscovery({
    required Strategy strategy,
    required String serviceId,
  }) {
    final identity = _identityManager.localIdentityJson;

    return _adapter.startDiscovery(
      identity,
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
      _endpointManager.isConnected(endpointId);

  bool isUserIdConnected(String userId) =>
      _endpointManager.isUserIdConnected(userId);

  Future<void> connect(String endpointId) async {
    if (isConnected(endpointId)) return;

    await stopDiscovery();

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final identity = _identityManager.localIdentityJson;

      await _adapter.requestConnection(
        identity,
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
    _endpointManager.markConnected(endpointId);
    _streamNotifier.notifyConnectedEndpoints(
      _endpointManager.getConnectedEndpointsCopy(),
    );
    _notifyKnownEndpoints();
  }

  Future<void> disconnect(String endpointId) async {
    await _adapter.disconnectFromEndpoint(endpointId);
    _endpointManager.markDisconnected(endpointId);
  }

  NearbyIdentityModel getIdentityByUserId(String userId) {
    return _endpointManager.getIdentityByUserId(userId) ??
        NearbyIdentityModel(
          uuid: userId,
          displayName: getDisplayNameByUserId(userId),
        );
  }

  String? getEndpointIdByUserId(String userUuid) {
    return _endpointManager.getEndpointIdByUserId(userUuid);
  }

  String getDisplayNameByEndpoint(String endpointId) {
    return _endpointManager.getDisplayNameByEndpoint(endpointId);
  }

  String getDisplayNameByUserId(String userId) {
    return _endpointManager.getDisplayNameByUserId(userId);
  }

  /// Sends bytes payload to the given endpoint.
  /// Returns true when the adapter reports success, false otherwise.
  Future<bool> sendBytes(String endpointId, Uint8List bytes) async {
    if (!isConnected(endpointId)) return false;

    try {
      await _adapter.sendBytesPayload(endpointId, bytes);
      return true;
    } catch (e, st) {
      Logger.log(
        error: 'Error sending bytes to $endpointId: $e',
        stackTrace: st,
      );
      return false;
    }
  }

  Future<int?> sendFile({
    required String endpointId,
    required String filePath,
  }) async {
    if (!isConnected(endpointId)) return null;

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        Logger.log(error: 'File does not exist: $filePath');
        return null;
      }
      return await _adapter.sendFilePayload(endpointId, filePath);
    } catch (e) {
      Logger.log(error: 'Error sending file: $e');
      return null;
    }
  }

  void _handleIncomingConnection(String endpointId, ConnectionInfo info) async {
    final identity = NearbyIdentityModel.fromJson(info.endpointName);
    _endpointManager.addEndpoint(endpointId, identity);
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
    String identityJson,
    String serviceId,
  ) {
    final identity = NearbyIdentityModel.fromJson(identityJson);
    _endpointManager.addEndpoint(endpointId, identity);
    _notifyKnownEndpoints();
  }

  void _handleEndpointLost(String? endpointId) {
    if (endpointId != null) _removeEndpoint(endpointId);
  }

  void _handlePayloadReceived(String endpointId, Payload payload) {
    if (payload.type == PayloadType.BYTES && payload.bytes == null) return;

    if (!_endpointManager.isConnected(endpointId)) {
      _markConnected(endpointId);
    }

    _payloadManager.handlePayloadReceived(endpointId, payload);
  }

  void _handlePayloadTransfer(String endpointId, PayloadTransferUpdate update) {
    _payloadManager.handlePayloadTransfer(endpointId, update);
  }

  void _removeEndpoint(String endpointId) {
    _endpointManager.removeEndpoint(endpointId);
    _streamNotifier.notifyConnectedEndpoints(
      _endpointManager.getConnectedEndpointsCopy(),
    );
    _notifyKnownEndpoints();
  }

  void _notifyKnownEndpoints() {
    final copy = _endpointManager.getEndpointsCopy();
    _streamNotifier.notifyDiscoveredEndpoints(copy);
    _streamNotifier.notifyAllKnownEndpoints(
      _endpointManager.getEndpointsCopy(),
    );
  }

  Future<void> dispose() async {
    await stopAll();
    await _payloadManager.dispose();
    await _streamNotifier.dispose();
  }
}
