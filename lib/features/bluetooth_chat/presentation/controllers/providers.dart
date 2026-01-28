import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/providers/core_providers.dart';
import '../../data/datasource/bluetooth_service.dart';
import '../../data/repositories/bluetooth_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/bluetooth_device_entity.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/entities/message.dart';
import 'bluetooth_controller.dart';
import 'bluetooth_state.dart';
import 'chat_controller.dart';

final chatControllerProvider = NotifierProvider<ChatController, List<Message>>(
  () {
    return ChatController();
  },
);

/// Low-level Bluetooth adapter + connection manager.
final bluetoothAdapterProvider = Provider<BluetoothAdapter>((ref) {
  final raw = FlutterBluetoothSerial.instance;
  return BluetoothAdapter(raw);
});

final connectionManagerProvider = Provider<BluetoothConnectionManager>((ref) {
  final adapter = ref.watch(bluetoothAdapterProvider);
  final manager = BluetoothConnectionManager(adapter);
  ref.onDispose(manager.dispose);
  return manager;
});

final chatRepository = Provider((ref) {
  final connectionManager = ref.watch(connectionManagerProvider);
  final myUserId = ref.watch(userRepositoryProvider).currentUser!.id;
  final sessionManager = ref.read(chatSessionManagerProvider);

  final repo = ChatRepositoryImpl(
    connectionManager,
    sessionManager,
    myUserId: myUserId,
  );
  ref.onDispose(repo.dispose);

  return repo;
});

final bluetoothProvider = Provider((ref) {
  return FlutterBluetoothSerial.instance;
});

final bluetoothRepositoryProvider = Provider((ref) {
  final bluetooth = ref.read(bluetoothProvider);
  return BluetoothRepositoryImpl(bluetooth);
});

final bluetoothControllerProvider =
    NotifierProvider<BluetoothController, BluetoothManageState>(() {
      return BluetoothController();
    });

final getBoundedDevicesProvider =
    FutureProvider.autoDispose<List<BluetoothDeviceEntity>>((ref) {   
     
      final controller = ref.read(bluetoothControllerProvider.notifier);
      return  controller.getPairedDevices();
    });

final chatSessionManagerProvider = Provider((_) {
  return ChatSessionManager();
});
//
