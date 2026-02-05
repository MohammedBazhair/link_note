import 'dart:typed_data';

/// Incoming bytes received from a peer endpoint.
class IncomingFrame {
  IncomingFrame({
    required this.peerEndpointId,
    this.bytes,
    this.payloadId,
    this.filePath, required this.messageId,
  });

  final String peerEndpointId;
  final Uint8List? bytes;
  final int? payloadId;
  final String? filePath;
final  String messageId;
}
