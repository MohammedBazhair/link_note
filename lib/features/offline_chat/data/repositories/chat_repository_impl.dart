import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/internal_constants/log.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasource/nearby_service.dart';
import '../models/incoming_frame.dart';
import '../models/protocol.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(
    this._connectionManager,
    this._sessionManager, {
    required String myUserId,
    required String myDisplayName,
  }) : _myUserId = myUserId,
       _myDisplayName = myDisplayName {
    _incomingSub = _connectionManager.incomingFrames.listen(_handleIncoming);
    _connectedSub = _connectionManager.connectedEndpointsStream.listen(
      _handleConnectedChange,
    );

    // Trigger handshake for any pre-existing connections
    Future.delayed(const Duration(milliseconds: 500), () {
      for (final endpointId in _connectionManager.knownEndpointIds) {
        if (_connectionManager.isConnected(endpointId)) {
          _handleConnectedChange({endpointId});
        }
      }
    });
  }

  final NearbyConnectionService _connectionManager;
  final ChatSessionManager _sessionManager;
  final String _myUserId;
  final String _myDisplayName;
  final _controller = StreamController<Message>.broadcast();
  final List<Message> _history = [];
  late final StreamSubscription<IncomingFrame> _incomingSub;
  late final StreamSubscription<Set<String>> _connectedSub;
  final Set<String> _handshakedEndpoints = {};
  final Map<int, String> _pendingImageSenders = {}; // payloadId -> senderUserId
  final Map<int, String> _completedFilePaths = {}; // payloadId -> filePath

  void _handleConnectedChange(Set<String> connectedIds) {
    for (final id in connectedIds) {
      if (!_handshakedEndpoints.contains(id)) {
        // Delay handshake slightly to ensure the native link is fully ready for bytes
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (_connectionManager.isConnected(id)) {
            _sendHandshake(id);
          }
        });
        _handshakedEndpoints.add(id);
      }
    }
    _handshakedEndpoints.retainAll(connectedIds);
  }

  @override
  Stream<Message> get messages => _controller.stream;

  @override
  List<Message> get messageHistory => List.unmodifiable(_history);

  void _sendHandshake(String endpointId) {
    Logger.log(message: 'Sending handshake to $endpointId');
    final packet = Protocol.buildPacket(
      senderUserId: _myUserId,
      type: MessageType.handshake,
      payload: utf8.encode(_myDisplayName),
    );
    _connectionManager.sendBytes(endpointId, packet);
  }

  void _handleIncoming(IncomingFrame frame) {
    Logger.log(message: 'Incoming frame from ${frame.peerEndpointId}');

    // 1. Handle file payload (image data completion)
    if (frame.payloadId != null && frame.filePath != null) {
      final payloadId = frame.payloadId!;
      _completedFilePaths[payloadId] = frame.filePath!;

      final senderId = _pendingImageSenders[payloadId];
      if (senderId != null) {
        _checkAndEmitImage(payloadId, senderId);
      }
      return;
    }

    // 2. If no bytes, we can't parse a protocol packet
    if (frame.bytes == null) return;

    try {
      final packet = Protocol.parsePacket(frame.bytes!);
      Logger.log(
        message:
            'Parsed packet: type=${packet.messageType}, sender=${packet.senderUserId}',
      );

      // ALWAYS UPDATE SESSION: Ensure we have the latest endpoint mapped to this UUID
      final session = ChatSession.create(
        myUserId: _myUserId,
        peerUserId: packet.senderUserId,
        peerAddress: frame.peerEndpointId,
      );
      _sessionManager.addSession(session);

      switch (packet.messageType) {
        case MessageType.handshake:
          final peerName = utf8.decode(packet.payload);
          Logger.log(
            message:
                'Handshake successful from ${packet.senderUserId} (Name: $peerName)',
          );
          if (peerName.isEmpty) return;

          _connectionManager.updateUuidMapping(
            uuid: packet.senderUserId,
            name: peerName,
          );
          return;

        case MessageType.image:
          final payloadId = int.tryParse(utf8.decode(packet.payload));
          if (payloadId == null) return;

          Logger.log(
            message:
                'Received image metadata for payload $payloadId from ${packet.senderUserId}',
          );
          _pendingImageSenders[payloadId] = packet.senderUserId;
          _checkAndEmitImage(payloadId, packet.senderUserId);
          return;

        case MessageType.text:
          break;
      }

      final message = Message.fromPacket(
        packet: packet,
        myId: _myUserId,
        senderId: packet.senderUserId,
      );

      Logger.log(
        message:
            'Message added to stream. From: ${message.senderUserId}, ChatID: ${message.chatId}',
      );

      _history.add(message);
      _controller.add(message);
    } catch (e, st) {
      Logger.log(error: 'Error in _handleIncoming: $e', stackTrace: st);
    }
  }

  void _checkAndEmitImage(int payloadId, String senderUserId) {
    final rawPath = _completedFilePaths[payloadId];
    if (rawPath == null) return;

    final pathWithExtension = '$rawPath.png';

    try {
      // Actually rename the file on disk so Image.file can find it
      final file = File(rawPath);
      if (file.existsSync()) {
        file.renameSync(pathWithExtension);
        Logger.log(message: 'File renamed to: $pathWithExtension');
      } else {
        Logger.log(error: 'Source file does not exist: $rawPath');
        return;
      }
    } catch (e) {
      Logger.log(error: 'Failed to rename received file: $e');
      // If rename fails, we'll keep the rawPath as a fallback in our logic
      // but the UI might fail if it expects pathWithExtension.
      // For now, let's just return if we can't ensure the file exists at the expected path.
      return;
    }

    Logger.log(message: 'Image fully received for payload $payloadId');
    final message = Message(
      id: const Uuid().v4(),
      senderUserId: senderUserId,
      type: MessageType.image,
      imagePath: pathWithExtension,
      time: DateTime.now().toUtc(),
      chatId: Message.buildChatId(_myUserId, senderUserId),
    );
    _history.add(message);
    _controller.add(message);

    _pendingImageSenders.remove(payloadId);
    _completedFilePaths.remove(payloadId);
  }

  /// Resolves a peer's Bluetooth address from their logical user id.
  ChatSession? _resolveSession(String peerUserId) {
    var session = _sessionManager.getSession(peerUserId);

    // RECOVERY LOGIC: If session is missing but we are connected, recreate it
    if (session == null) {
      Logger.log(
        message: 'Session NULL for $peerUserId. Attempting recovery...',
      );
      final endpointId = _connectionManager.getEndpointIdByUserId(peerUserId);
      if (endpointId != null && _connectionManager.isConnected(endpointId)) {
        Logger.log(
          message: 'Recovering missing session for $peerUserId at $endpointId',
        );
        session = ChatSession.create(
          myUserId: _myUserId,
          peerUserId: peerUserId,
          peerAddress: endpointId,
        );
        _sessionManager.addSession(session);
      } else {
        Logger.log(
          error:
              'Recovery failed for $peerUserId. Unknown or disconnected endpoint.',
        );
      }
    }
    return session;
  }

  @override
  void sendText({required String peerUserId, required String text}) {
    Logger.log(message: 'sendText called. peerUserId: $peerUserId');
    final session = _resolveSession(peerUserId);
    if (session == null) {
      Logger.log(error: 'No active session for peer $peerUserId');
      return;
    }

    final payload = Uint8List.fromList(utf8.encode(text));
    final packet = Protocol.buildPacket(
      senderUserId: _myUserId,
      type: MessageType.text,
      payload: payload,
    );
    Logger.log(message: 'Sending text to ${session.peerAddress}');
    _connectionManager.sendBytes(session.peerAddress, packet);

    // Add to local stream so it shows in UI
    final message = Message(
      id: const Uuid().v4(),
      senderUserId: _myUserId,
      type: MessageType.text,
      text: text,
      time: DateTime.now().toUtc(),
      chatId: Message.buildChatId(_myUserId, peerUserId),
    );
    _history.add(message);
    _controller.add(message);
  }

  @override
  Future<void> sendImage({
    required String peerUserId,
    required String filePath,
  }) async {
    final session = _resolveSession(peerUserId);

    if (session == null) {
      Logger.log(error: 'No active session for peer $peerUserId');
      return;
    }

    final payloadId = await _connectionManager.sendFile(
      endpointId: session.peerAddress,
      filePath: filePath,
    );

    if (payloadId == null) {
      Logger.log(error: 'Failed to start file transfer');
      return;
    }

    Logger.log(message: 'File transfer started: $payloadId. Sending metadata.');
    final metadataPacket = Protocol.buildPacket(
      senderUserId: _myUserId,
      type: MessageType.image,
      payload: Uint8List.fromList(utf8.encode(payloadId.toString())),
    );
    await _connectionManager.sendBytes(session.peerAddress, metadataPacket);

    // Add to local stream immediately for feedback
    final message = Message(
      id: const Uuid().v4(),
      senderUserId: _myUserId,
      type: MessageType.image,
      imagePath: filePath,
      time: DateTime.now().toUtc(),
      chatId: Message.buildChatId(_myUserId, peerUserId),
    );
    _history.add(message);
    _controller.add(message);
  }

  @override
  void dispose() {
    _incomingSub.cancel();
    _connectedSub.cancel();
    _controller.close();
  }
}
