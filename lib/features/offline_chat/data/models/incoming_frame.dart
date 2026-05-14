import 'dart:typed_data';

/// Incoming bytes received from a peer endpoint.
class IncomingFrame {
  IncomingFrame({
    required this.peerEndpointId,
    required this.messageId,
     this.replyToMessageId,
    this.bytes,
    this.payloadId,
    this.filePath,
  });

  final String peerEndpointId;
  final Uint8List? bytes;
  final int? payloadId;
  final String? filePath;
  final String messageId;
  final String? replyToMessageId;
}
