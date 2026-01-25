import 'package:flutter/material.dart';

import 'overlay_mask_painter.dart';
import 'scanner_animated_builder.dart';

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key, required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Overlay layer
        CustomPaint(size: Size.infinite, painter: OverlayMaskPainter(size)),

        // Scan frame
        ScannerAnimatedBuilder(size: size),

        // Info text below the frame
        const Positioned(
          bottom: -33,
          left: 0,
          right: 0,
          child: Text(
            'امسح الرمز في داخل هذا الإطار',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xD8FFFFFF)),
          ),
        ),
      ],
    );
  }
}
