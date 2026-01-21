import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../image/presentation/controllers/image_providers.dart';
import '../controller/qr_providers.dart';
import '../controller/qr_state.dart';
import '../widgets/filled_icon_button.dart';
import '../widgets/scanner_overlay.dart';

void handleQrStates(BuildContext context, QrState state) {
  switch (state) {
    case QrInitialState():
    case QrScanningState():
    case QrCameraUpdatedState():
      break;
    case QrImageSavedState(:final imageName):
      context.showSnakbar('تم حفظ الصورة في المعرض باسم $imageName');
    case QrScannedDoneState(:final message):
    case QrErrorState(:final message):
      context.showSnakbar(message);
  }
}

class ScannerQrCodeScreen extends ConsumerWidget {
  const ScannerQrCodeScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cameraArea = screenWidth * 0.7;
    final scanArea = cameraArea - 60;
    ref.listen(qrControllerProvider, (_, state) {
      handleQrStates(context,state);
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
                      onPressed: ref
                          .read(qrControllerProvider.notifier)
                          .switchCamera,
                      iconData: Icons.flip_camera_android_rounded,
                    ),
                    Consumer(
                      builder: (_, ref, __) {
                        final isFlashOn = ref
                            .watch(qrControllerProvider)
                            .scannerState
                            .isFlashOn;
                        return FilledIconButton(
                          onPressed: ref
                              .read(qrControllerProvider.notifier)
                              .toggleFlash,
                          iconData: isFlashOn
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_outlined,
                        );
                      },
                    ),
                    FilledIconButton(
                      onPressed: () async {
                        final path = await ref
                            .read(imagePickerControllerProvider.notifier)
                            .pickImage();
                        if (path == null) return;
                        await ref
                            .read(qrControllerProvider.notifier)
                            .analyzeImage(path);
                      },
                      iconData: Icons.image_sharp,
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
