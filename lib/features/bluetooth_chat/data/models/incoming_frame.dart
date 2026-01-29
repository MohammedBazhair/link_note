import 'dart:typed_data';

/// Incoming bytes received from a peer endpoint.
class IncomingFrame {
  IncomingFrame({required this.peerEndpointId, required this.bytes});

  final String peerEndpointId;
  final Uint8List bytes;
}
