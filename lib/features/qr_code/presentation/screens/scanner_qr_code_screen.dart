import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../widgets/scanner_overlay.dart';

class ScannerQrCodeScreen extends StatefulWidget {
  const ScannerQrCodeScreen({super.key});

  @override
  State<ScannerQrCodeScreen> createState() => _ScannerQrCodeScreenState();
}

class _ScannerQrCodeScreenState extends State<ScannerQrCodeScreen> {
  bool isFlashOn = false;
  bool isFrontCamera = false;
  bool canScan = true;
  MobileScannerController cameraController = MobileScannerController();
  Timer? timerDebounce;

  @override
  void dispose() {
    cameraController.dispose();
    timerDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cameraArea = screenWidth * 0.7;

    final scanArea = cameraArea - 60;
    return Scaffold(
      appBar: AppBar(title: const Text('مسح رمز QR')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'امسح رمز QR لاستخراج ملاحظة.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: cameraArea,
                  height: cameraArea,
                  child: MobileScanner(
                    controller: cameraController,
                    onDetect: (result) {
                      if (!canScan) return;

                      canScan = false;

                      final rawValue = result.barcodes.first.rawValue;
                      if (rawValue?.isNotEmpty ?? false) {
                        Navigator.of(context).pop<String>(rawValue);
                      }

                      timerDebounce?.cancel();
                      timerDebounce = Timer(const Duration(seconds: 2), () {
                        canScan = true;
                      });
                    },
                  ),
                ),
              ),

              // الحد يظهر فوق الكاميرا
              Container(
                width: cameraArea,
                height: cameraArea,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0x86AEF7FA),
                    width: 0.5,
                  ),
                ),
              ),

              // ignore: prefer_const_constructors
              ScannerOverlay(
                height: scanArea,
                width: scanArea,
                borderRadius: 30,

                borderThickness: 1,
              ),
            ],
          ),
          const SizedBox(height: 40),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              IconButton(
                onPressed: () async {
                  setState(() => isFlashOn = !isFlashOn);
                  await cameraController.toggleTorch();
                },
                icon: Icon(
                  isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  size: 35,
                ),
              ),
              IconButton(
                onPressed: () async {
                  setState(() => isFrontCamera = !isFrontCamera);
                  await cameraController.switchCamera();
                },
                icon: const Icon(Icons.flip_camera_android_rounded, size: 35),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
