import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controller/qr_providers.dart';
import '../handle_qr_states.dart';
import '../widgets/scanner_actions.dart';
import '../widgets/scanner_overlay.dart';

class ScannerQrCodeScreen extends ConsumerWidget {
  const ScannerQrCodeScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cameraArea = screenWidth * 0.7;
    final scanArea = cameraArea - 60;
    final centerPoint = Offset(screenWidth / 2, screenHeight / 2);
    ref.listen(qrControllerProvider, (_, state) {
      handleQrStates(context, state);
    });
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Camera preview
          MobileScanner(
            controller: ref.read(moblieScannerProvider),
            onDetect: ref.read(qrControllerProvider.notifier).onDetect,
            scanWindow: Rect.fromCenter(
              center: centerPoint,
              width: scanArea,
              height: scanArea,
            ),
            overlayBuilder: (_, _) {
              return ScannerOverlay(size: Size.square(scanArea));
            },
          ),

          // Top buttons (Back, Camera flip, Flash)
          const Align(alignment: Alignment.topCenter, child: ScannerActions()),
        ],
      ),
    );
  }
}
