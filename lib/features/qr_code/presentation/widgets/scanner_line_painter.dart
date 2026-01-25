import 'package:flutter/material.dart';

class ScannerLinePainter extends CustomPainter {
  ScannerLinePainter(this.controller) : super(repaint: controller);
  final AnimationController controller;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final dy = controller.value * size.height;

    final firstPoint = Offset(3, dy);
    final secondPoint = Offset(size.width - 3, dy);
    canvas.drawLine(firstPoint, secondPoint, paint);
  }

  @override
  bool shouldRepaint(ScannerLinePainter oldDelegate) {
    return oldDelegate.controller.value != controller.value;
  }
}
