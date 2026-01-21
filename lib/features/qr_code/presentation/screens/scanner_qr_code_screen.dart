import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../widgets/filled_icon_button.dart';
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
  final MobileScannerController cameraController = MobileScannerController();
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
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Camera preview
          MobileScanner(
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

          // Overlay
          ScannerOverlay(width: scanArea, height: scanArea, borderRadius: 8),

          // Top buttons (Back, Camera flip, Flash)
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                child: Row(
                  spacing: 22,
                  children: [
                    const BackButton(color: Colors.white),
                    const Spacer(),
                    FilledIconButton(
                      onPressed: () async {
                        setState(() => isFrontCamera = !isFrontCamera);
                        await cameraController.switchCamera();
                      },
                      iconData: Icons.flip_camera_android_rounded,
                    ),
                    FilledIconButton(
                      onPressed: () async {
                        setState(() => isFlashOn = !isFlashOn);
                        await cameraController.toggleTorch();
                      },
                      iconData: isFlashOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_outlined,
                    ),
                    const Spacer(),
                    const AbsorbPointer(
                      child: BackButton(color: Colors.transparent),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
