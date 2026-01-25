import 'package:flutter/material.dart';

class OverlayMaskPainter extends CustomPainter {
  const OverlayMaskPainter(this.innerSize);
final  Size innerSize;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);

    final outer = Rect.fromLTWH(0, 0, size.width, size.height);
    final inner = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width,
        height: size.height,
      ),
      const Radius.circular(10),
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
