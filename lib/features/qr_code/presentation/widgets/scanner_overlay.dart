import 'package:flutter/material.dart';

import 'overlay_frame_painter.dart';
import 'overlay_mask_painter.dart';

/// Widget that combines the semi-transparent overlay with the scan frame.
class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({
    super.key,
    required this.width,
    required this.height,
    this.borderColor = Colors.white,
    this.borderThickness = 2,
    this.borderRadius = 20,
    this.infoText = 'امسح رمز QR داخل الإطار.',
  });

  final double width;
  final double height;
  final Color borderColor;
  final double borderThickness;
  final double borderRadius;
  final String infoText;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Overlay layer
        CustomPaint(
          size: Size.infinite,
          painter: OverlayMaskPainter(
            width: width,
            height: height,
            borderRadius: borderRadius,
          ),
        ),

        // Scan frame
        SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: OverlayFramePainter(
              paintColor: borderColor,
              borderThickness: borderThickness,
              borderRadius: borderRadius,
            ),
          ),
        ),

        // Info text below the frame
        Positioned(
          bottom: -33,
          left: 0,
          right: 0,
          child: Text(
            infoText,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xD8FFFFFF)),
          ),
        ),

       
      ],
    );
  }
}
