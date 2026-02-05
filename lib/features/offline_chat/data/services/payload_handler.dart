import 'dart:async';

import 'package:nearby_connections/nearby_connections.dart';

import '../models/incoming_frame.dart';

/// Handles payload transfers and file management
class NearbyPayloadManager {
  final Map<int, String> _payloadPaths = {};

  final _incomingStreamController = StreamController<IncomingFrame>.broadcast();
  Stream<IncomingFrame> get incomingFrames => _incomingStreamController.stream;

  void handlePayloadReceived(String endpointId, Payload payload) {
    if (payload.type == PayloadType.BYTES && payload.bytes == null) return;

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
    
        if (payload.filePath != null) {
          _payloadPaths[payload.id] = payload.filePath!;
        }
      case PayloadType.NONE:
      case PayloadType.STREAM:
    }
  }

  void handlePayloadTransfer(String endpointId, PayloadTransferUpdate update) {
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

  Future<void> dispose() async {
    await _incomingStreamController.close();
  }
}
