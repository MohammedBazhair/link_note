import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../domain/entities/scanner_state.dart';
import 'qr_controller.dart';
import 'qr_state.dart';

final moblieScannerProvider = Provider((ref) {
  final controller = MobileScannerController();
  ref.onDispose(controller.dispose);
  return controller;
});

final qrControllerProvider = StateNotifierProvider<QrController, QrState>((
  ref,
) {
  final mobileController = ref.read(moblieScannerProvider);
  return QrController(mobileController);
});

final scannerStateProcider = StateProvider.autoDispose((ref) => ScannerState());

final timerDebounceProvider = StateProvider<Timer?>((ref) {
  return null;
});
