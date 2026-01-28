import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/bluetooth_device_entity.dart';
import '../../domain/repositories/bluetooth_repository.dart';
import 'bluetooth_state.dart';
import 'providers.dart';

class BluetoothController extends Notifier<BluetoothManageState> {
  late final BluetoothRepository _bluetoothRepo;

  /// التحقق من البلوتوث وتحديث الحالة
  Future<void> checkBluetooth() async {
    try {
      final enabled = await _bluetoothRepo.isEnabled();
      state = state.copyWith(isEnabled: enabled);

      if (!enabled) {
        final requested = await _bluetoothRepo.requestEnable();
        state = state.copyWith(isEnabled: requested);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// جلب الأجهزة المقترنة مسبقاً
  Future<List<BluetoothDeviceEntity>> getPairedDevices() async {
    try {
      final paired = await _bluetoothRepo.getPairedDevices();
      paired.sort(
        (a, b) => (b.isConnected ? 1 : 0).compareTo(a.isConnected ? 1 : 0),
      );
      state = state.copyWith(pairedDevices: paired);
      return paired;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return state.pairedDevices;
    }
  }

  /// قطع الاتصال
  Future<void> disconnect() async {
    try {
      await _bluetoothRepo.disconnect();
    } catch (e) {
      state = state.copyWith(error: 'Failed to disconnect: $e');
    }
  }

  Future<void> openBluetoothSettings() {
    return _bluetoothRepo.openBluetoothSettings();
  }

  @override
  BluetoothManageState build() {
    _bluetoothRepo = ref.read(bluetoothRepositoryProvider);
    return BluetoothManageState(isEnabled: false);
  }
}
