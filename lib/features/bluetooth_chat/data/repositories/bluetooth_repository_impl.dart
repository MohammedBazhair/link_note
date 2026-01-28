import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../../domain/entities/bluetooth_device_entity.dart';
import '../../domain/repositories/bluetooth_repository.dart';

class BluetoothRepositoryImpl implements BluetoothRepository {
  BluetoothRepositoryImpl(this._bt);

  final FlutterBluetoothSerial _bt;

  StreamController<BluetoothDeviceEntity>? _discoveryController;

  @override
  Future<bool> isEnabled() async => await _bt.isEnabled ?? false;

  @override
  Future<bool> requestEnable() async => await _bt.requestEnable() ?? false;

  @override
  Stream<BluetoothDeviceEntity> discoverDevices() {
    _discoveryController = StreamController<BluetoothDeviceEntity>.broadcast();

    _bt.startDiscovery().listen(
      (r) {
        _discoveryController!.add(BluetoothDeviceEntity.from(r.device));
      },
      onDone: () {
        _discoveryController?.close();
      },
    );

    return _discoveryController!.stream;
  }

  @override
  Future<void> connect(BluetoothDevice device) async {
    await _bt.connect(device);
  }

  @override
  Future<void> disconnect() async {
    // قطع الاتصال
    await _bt.disconnect();
  }

  @override
  Future<List<BluetoothDeviceEntity>> getPairedDevices() async {
    final devices = await _bt.getBondedDevices();
    return devices.map(BluetoothDeviceEntity.from).toList();
  }

  @override
  Future<void> openBluetoothSettings() {
    return _bt.openSettings();
  }
}
