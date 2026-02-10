import 'dart:async';

import 'package:nearby_connections/nearby_connections.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/internal_constants/log.dart';
import '../models/incoming_frame.dart';
import '../models/protocol.dart';

/// Handles payload transfers and file management
class NearbyPayloadManager {
  final Map<int, String> _payloadPaths = {};
  final Map<int, String> _payloadMessagesIds = {};

  final _incomingStreamController = StreamController<IncomingFrame>.broadcast();
  Stream<IncomingFrame> get incomingFrames => _incomingStreamController.stream;

  void handlePayloadReceived(String endpointId, Payload payload) {
    if (payload.type == PayloadType.BYTES && payload.bytes == null) {
      Logger.log(
        message:
            'Received BYTES payload with null bytes from $endpointId id=${payload.id}',
      );
      return;
    }

    try {
      Logger.log(
        message:
            'handlePayloadReceived endpoint=$endpointId id=${payload.id} type=${payload.type}',
      );

      switch (payload.type) {
        case PayloadType.BYTES:
          final packet = Protocol.parsePacket(payload.bytes!);
          Logger.log(
            message:
                'Parsed packet from $endpointId messageId=${packet.messageId} type=${packet.messageType}',
          );
          _payloadMessagesIds[payload.id] = packet.messageId;

          _incomingStreamController.add(
            IncomingFrame(
              peerEndpointId: endpointId,
              payloadId: payload.id,
              bytes: payload.bytes,
              messageId: packet.messageId,
              replyToMessageId: packet.replyToMessageId,
            ),
          );
          break;
        case PayloadType.FILE:
          if (payload.filePath != null) {
            Logger.log(
              message:
                  'Received FILE payload from $endpointId id=${payload.id} path=${payload.filePath}',
            );
            _payloadPaths[payload.id] = payload.filePath!;
          }
          break;
        case PayloadType.NONE:
        case PayloadType.STREAM:
          Logger.log(
            message:
                'Received unsupported payload type ${payload.type} from $endpointId id=${payload.id}',
          );
          break;
      }
    } catch (e, st) {
      Logger.log(error: 'Error in handlePayloadReceived: $e', stackTrace: st);
    }
  }

  void handlePayloadTransfer(String endpointId, PayloadTransferUpdate update) {
    switch (update.status) {
      case PayloadStatus.IN_PROGRESS:
        break;
      case PayloadStatus.SUCCESS:
        Logger.log(
          message:
              'Payload transfer SUCCESS endpoint=$endpointId id=${update.id}',
        );
        final path = _payloadPaths.remove(update.id);
        final messageId = _payloadMessagesIds.remove(update.id);

        _incomingStreamController.add(
          IncomingFrame(
            peerEndpointId: endpointId,
            payloadId: update.id,
            filePath: path,
            messageId: messageId ?? const Uuid().v4(),
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
