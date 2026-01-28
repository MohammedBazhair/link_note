import '../../domain/entities/bluetooth_device_entity.dart';

class BluetoothManageState {
  BluetoothManageState({
    required this.isEnabled,
    this.isDiscovering = false,
    this.discoveredDevices = const [],
    this.pairedDevices = const [],
  });
  final bool isEnabled;
  final bool isDiscovering;
  final List<BluetoothDeviceEntity> discoveredDevices;
  final List<BluetoothDeviceEntity> pairedDevices;

  BluetoothManageState copyWith({
    bool? isEnabled,
    bool? isDiscovering,
    List<BluetoothDeviceEntity>? discoveredDevices,
    List<BluetoothDeviceEntity>? pairedDevices,
    String? error,
  }) {
    return BluetoothManageState(
      isEnabled: isEnabled ?? this.isEnabled,
      isDiscovering: isDiscovering ?? this.isDiscovering,
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      pairedDevices: pairedDevices ?? this.pairedDevices,
    );
  }
}
