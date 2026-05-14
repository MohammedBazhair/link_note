import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

Future<bool> ensureBluetoothEnabled() async {
  final enabled = await BluetoothEnable.enableBluetooth;

  return enabled == 'true';
}

Future<bool> ensureLocationEnabled() async {
  final location = loc.Location();

  bool enabled = await location.serviceEnabled();
  if (!enabled) enabled = await location.requestService();

  return enabled;
}

Future<bool> requestNearbyPermissions() async {
  final androidInfo = await DeviceInfoPlugin().androidInfo;
  final permissions = <Permission>[Permission.location];
  final sdk = androidInfo.version.sdkInt;

  if (sdk >= 31) {
    permissions.addAll([
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
    ]);
  }

  if (sdk >= 33) {
    permissions.add(Permission.nearbyWifiDevices);
  }

  final statuses = await permissions.request();

  final location = loc.Location();

  final locationPermission = await location.requestPermission();
  final isLocationGranted = locationPermission == loc.PermissionStatus.granted;
  final allGranted = statuses.values.every((s) => s.isGranted);
  if (!allGranted || !isLocationGranted) await openAppSettings();

  return allGranted && isLocationGranted;
}
