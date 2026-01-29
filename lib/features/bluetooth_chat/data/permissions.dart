import 'package:device_info_plus/device_info_plus.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

Future<void> ensureLocationReady() async {
  final location = loc.Location();

  bool enabled = await location.serviceEnabled();
  if (!enabled)   enabled = await location.requestService();
  

  final permission = await location.hasPermission();
  if (permission == loc.PermissionStatus.denied) {
    await location.requestPermission();
  }
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
  await ensureLocationReady();
  final allGranted = statuses.values.every((s) => s.isGranted);
  if (!allGranted) await openAppSettings();
  return allGranted;
}
