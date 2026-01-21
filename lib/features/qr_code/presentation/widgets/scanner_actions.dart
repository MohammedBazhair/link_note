import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors/colors.dart';
import '../../../../core/constants/internal_constants/log.dart';
import '../../../image/presentation/controllers/image_providers.dart';
import '../controller/qr_providers.dart';
import '../widgets/filled_icon_button.dart';

class ScannerActions extends StatelessWidget {
  const ScannerActions({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          spacing: 22,
          children: [
            const BackButton(color: Colors.white),
            const Spacer(),
            Consumer(
              builder: (_, ref, __) {
                final isFrontCamera = ref.watch(
                  qrControllerProvider.select(
                    (s) => s.scannerState.isFrontCamera,
                  ),
                );
                return FilledIconButton(
                  onPressed: ref
                      .read(qrControllerProvider.notifier)
                      .switchCamera,
                  iconData: Icons.flip_camera_android_rounded,
                  backgroundColor: isFrontCamera
                      ? DarkColors.primary.withOpacity(0.8)
                      : null,
                );
              },
            ),
            Consumer(
              builder: (_, ref, __) {
                final isFlashOn = ref.watch(
                  qrControllerProvider.select((s) => s.scannerState.isFlashOn),
                );
                Logger.log(message: isFlashOn.toString());
                return FilledIconButton(
                  onPressed: ref
                      .read(qrControllerProvider.notifier)
                      .toggleFlash,
                  iconData: isFlashOn
                      ? Icons.flash_on_rounded
                      : Icons.flash_off_outlined,
                  backgroundColor: isFlashOn
                      ? DarkColors.primary.withOpacity(0.8)
                      : null,
                );
              },
            ),
            Consumer(
              builder: (_, ref, __) {
                return FilledIconButton(
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
                  backgroundColor: DarkColors.primary.withOpacity(0.8),
                );
              },
            ),

            const Spacer(),
            const AbsorbPointer(child: BackButton(color: Colors.transparent)),
          ],
        ),
      ),
    );
  }
}
