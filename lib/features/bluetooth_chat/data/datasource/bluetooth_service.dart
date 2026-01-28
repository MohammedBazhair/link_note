import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

/// --- Adapter Layer: إدارة البلوتوث الخام ---
class BluetoothAdapter {
  BluetoothAdapter(this._bluetooth);

  final FlutterBluetoothSerial _bluetooth;

  FlutterBluetoothSerial get raw => _bluetooth;

  /// يفتح اتصال مع جهاز معين
  Future<BluetoothConnection> connect(String address) {
    return BluetoothConnection.toAddress(address);
  }

  /// يغلق اتصال معين
  Future<void> disconnect(BluetoothConnection connection) async {
    await connection.close();
  }

  /// طلب كل الصلاحيات المطلوبة للعمل مع Classic Bluetooth
  static Future<bool> requestBluetoothPermissions() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.location,
    ].request();

    final allGranted = statuses.values.every((status) => status.isGranted);

    if (!allGranted) {
      // اجبر المستخدم على تفعيل الصلاحيات من إعدادات التطبيق
      await openAppSettings();
      return false;
    }

    return true;
  }

  /// التحقق هل البلوتوث مفعل
  Future<bool> isEnabled() async => await _bluetooth.isEnabled ?? false;

  /// طلب تفعيل البلوتوث (يفتح نافذة النظام)
  Future<bool> requestEnable() async =>
      await _bluetooth.requestEnable() ?? false;
}

/// --- Incoming Frame: هيكل الرسالة القادمة من جهاز ---
class IncomingFrame {
  IncomingFrame({required this.peerAddress, required this.bytes});

  final String peerAddress;
  final Uint8List bytes;
}

/// --- Connection Manager: يدير كل الاتصالات النشطة مع الأجهزة ---
class BluetoothConnectionManager {
  BluetoothConnectionManager(this._adapter);

  final BluetoothAdapter _adapter;

  final Map<String, BluetoothConnection> _connections = {};
  final Map<String, BytesBuilder> _buffers = {};

  /// بث لجميع الرسائل القادمة من أي جهاز
  final StreamController<IncomingFrame> _incomingController =
      StreamController<IncomingFrame>.broadcast();

  Stream<IncomingFrame> get incoming => _incomingController.stream;

  /// الحد الأدنى لطول الرأس في البروتوكول
  static const int _headerLength = 5;

  /// يضمن وجود اتصال واحد لكل جهاز
  Future<BluetoothConnection> ensureConnection(String peerAddress) async {
    final existing = _connections[peerAddress];
    if (existing != null && existing.isConnected) {
      return existing;
    }

    final connection = await _adapter.connect(peerAddress);
    _registerConnection(peerAddress, connection);
    return connection;
  }

  void _registerConnection(String peerAddress, BluetoothConnection connection) {
    _connections[peerAddress] = connection;
    _buffers[peerAddress] = BytesBuilder();

    connection.input?.listen(
      (data) {
        final buffer = _buffers[peerAddress]!..add(data);
        var bufferData = buffer.toBytes();

        // تحليل الرسائل الكاملة
        while (bufferData.length >= _headerLength) {
          final view = ByteData.sublistView(bufferData, 1, _headerLength);
          final payloadLength = view.getUint32(0);
          final frameLength = _headerLength + payloadLength;

          if (bufferData.length < frameLength) break;

          final frameBytes = Uint8List.sublistView(bufferData, 0, frameLength);
          _incomingController.add(
            IncomingFrame(peerAddress: peerAddress, bytes: frameBytes),
          );

          bufferData = Uint8List.sublistView(bufferData, frameLength);
        }

        // حفظ الباقي (جزئية الرسالة)
        _buffers[peerAddress] = BytesBuilder()..add(bufferData);
      },
      onDone: () {
        _connections.remove(peerAddress);
        _buffers.remove(peerAddress);
      },
      onError: (_) {
        _connections.remove(peerAddress);
        _buffers.remove(peerAddress);
      },
      cancelOnError: true,
    );
  }

  /// إرسال رسالة لجهاز محدد
  Future<void> send(String peerAddress, Uint8List data) async {
    final connection = _connections[peerAddress];
    if (connection == null || !connection.isConnected) return;

    connection.output.add(data);
    await connection.output.allSent;
  }

  /// إرسال رسالة لجميع الأجهزة المتصلة
  Future<void> sendToAll(Uint8List data) async {
    for (final entry in _connections.entries) {
      if (entry.value.isConnected) {
        entry.value.output.add(data);
      }
    }
  }

  /// إغلاق اتصال مع جهاز معين
  Future<void> closePeer(String peerAddress) async {
    final connection = _connections.remove(peerAddress);
    _buffers.remove(peerAddress);
    if (connection != null) {
      await connection.close();
    }
  }

  /// التخلص من جميع الموارد وإغلاق كل الاتصالات
  Future<void> dispose() async {
    for (final address in _connections.keys.toList(growable: false)) {
      await closePeer(address);
    }
    await _incomingController.close();
  }

}
