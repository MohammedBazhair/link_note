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
    final cameraArea = screenWidth * 0.7;
    final scanArea = cameraArea - 60;
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
            onDetect: (result) {},
          ),

          // Overlay
          ScannerOverlay(width: scanArea, height: scanArea, borderRadius: 8),

          // Top buttons (Back, Camera flip, Flash)
          const Align(alignment: Alignment.topCenter, child: ScannerActions()),
        ],
      ),
    );
  }
}
