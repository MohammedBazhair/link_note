// ignore_for_file: non_const_call_to_literal_constructor

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import '../../domain/entities/qr_data.dart';
import '../../domain/entities/scanner_state.dart';
import 'qr_state.dart';

class QrController extends StateNotifier<QrState> {
  QrController(this._sacnnerController)
    : super(QrInitialState(scannerState: ScannerState()));

  final MobileScannerController _sacnnerController;

  Future<void> onDetect(BarcodeCapture result) async {
    if (!state.scannerState.canScan) return;

    await _sacnnerController.stop();

    final newScannerState = state.scannerState.copyWith(canScan: false);
    state = QrScanningState(scannerState: newScannerState);

    final rawValue = result.barcodes.first.rawValue;



    if (rawValue?.isNotEmpty ?? false) {
      state = QrScannedDoneState(
        scannerState: state.scannerState,
        scannedRawResult: rawValue!,
        message: 'تم استخراج البيانات عند مسح الرمز بنجاح',
      );
    }

    await _sacnnerController.start();
    state = QrCameraUpdatedState(
      scannerState: state.scannerState.copyWith(canScan: true),
    );
  }

  Future<void> switchCamera() async {
    await _sacnnerController.switchCamera();
    final isFrontCamera = !state.scannerState.isFrontCamera;

    final newScannerState = state.scannerState.copyWith(
      isFrontCamera: isFrontCamera,
    );
    state = QrCameraUpdatedState(scannerState: newScannerState);
  }

  Future<void> toggleFlash() async {
    await _sacnnerController.toggleTorch();
    final isFlashOn = !state.scannerState.isFlashOn;

    final newScannerState = state.scannerState.copyWith(isFlashOn: isFlashOn);
    state = QrCameraUpdatedState(scannerState: newScannerState);
  }

  Future<void> analyzeImage(String imagePath) async {
    try {
      state = QrScanningState(scannerState: state.scannerState);
      final result = await _sacnnerController.analyzeImage(imagePath);
      final rawValue = result?.barcodes.firstOrNull?.rawValue;
      if (rawValue == null) throw ArgumentError();

      state = QrScannedDoneState(
        scannerState: state.scannerState,
        scannedRawResult: rawValue,
        message: 'تم استخراج البيانات من الصورة بنجاح',
      );
    } on UnsupportedError catch (_) {
      const message =
          'الملف الذي اخترته غير مدعوم ويجب أن يكون بامتداد صورة مدعومة';
      state = QrErrorState(scannerState: state.scannerState, message: message);
    } on MobileScannerBarcodeException catch (_) {
      const message = 'حدثت مشكلة أثناء محاولة مسح الصورة اختر صورة اخرى';
      state = QrErrorState(scannerState: state.scannerState, message: message);
    } on ArgumentError catch (_) {
      const message = 'الصورة المحددة لا تحتوي على رمز QR اختر صورة مناسبة';
      state = QrErrorState(scannerState: state.scannerState, message: message);
    }
  }

  Future<void> saveQrAsImage(QrData qrData) async {
    try {
      final qrCode = QrCode.fromData(
        data: qrData.qrCodeRaw,
        errorCorrectLevel: QrErrorCorrectLevel.H,
      );
      final qrImage = QrImage(qrCode);
      final byteData = await qrImage.toImageAsBytes(
        size: 512,
        decoration: PrettyQrDecoration(
          background: Colors.white,
          quietZone: PrettyQrPixelsQuietZone(20),
        ),
      );
      final imageBytes = byteData?.buffer.asUint8List();
      if (imageBytes == null) throw Exception();
      await ImageGallerySaverPlus.saveImage(imageBytes, name: qrData.name);
      state = QrImageSavedState(
        scannerState: state.scannerState,
        imageName: qrData.name,
      );
    } catch (e) {
      state = QrErrorState(
        scannerState: state.scannerState,
        message: 'حدث خطأ أثناء محاولة حفظ الصورة',
      );
    }
  }
}
