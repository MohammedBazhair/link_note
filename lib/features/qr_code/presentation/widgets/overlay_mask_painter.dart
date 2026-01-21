import 'package:flutter/material.dart';

class OverlayMaskPainter extends CustomPainter {
  OverlayMaskPainter({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);

    final outer = Rect.fromLTWH(0, 0, size.width, size.height);
    final inner = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2 , size.height / 2 ),
        width: width,
        height: height,
      ),
      Radius.circular(borderRadius),
    );

    final path = Path()
      ..addRect(outer)
      ..addRRect(inner)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
