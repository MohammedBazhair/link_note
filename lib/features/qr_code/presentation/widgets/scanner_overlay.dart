import 'package:flutter/material.dart';

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({
    super.key,
    required this.width,
    required this.height,
    this.borderColor = const Color(0x86AEF7FA),
    this.borderRadius = 0,
    this.borderThickness = 2,
  });
  final double width;
  final double height;
  final Color borderColor;
  final double borderRadius;
  final double borderThickness;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ظل المنطقة المحيطة
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),

        // المربع الداخلي الشفاف مع الحدود
        Center(
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor, width: borderThickness),
            ),
          ),
        ),
      ],
    );
  }
}
