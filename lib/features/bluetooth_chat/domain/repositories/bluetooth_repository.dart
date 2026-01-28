import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../entities/bluetooth_device_entity.dart';

abstract class BluetoothRepository {
  /// التحقق إذا البلوتوث مفعل
  Future<bool> isEnabled();

  /// طلب تفعيل البلوتوث (قد يفتح شاشة النظام)
  Future<bool> requestEnable();

  /// البحث عن الأجهزة القريبة (stream)
  Stream<BluetoothDeviceEntity> discoverDevices();

  /// الاتصال بجهاز
  Future<void> connect(BluetoothDevice device);

  /// قطع الاتصال
  Future<void> disconnect();

  Future<void> openBluetoothSettings();

  Future<List<BluetoothDeviceEntity>> getPairedDevices();
}
