import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothDeviceEntity {
  BluetoothDeviceEntity({
    required this.name,
    required this.address,
    required this.isConnected,
  });

  factory BluetoothDeviceEntity.from(BluetoothDevice device) {
 return   BluetoothDeviceEntity(
      name: device.name ?? '-',
      address: device.address,
      isConnected: device.isConnected,
    );
  }

  final String name;
  final bool isConnected;
  final String address;
}
