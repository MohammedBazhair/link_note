import 'package:flutter/material.dart';

/// Responsible for drawing the white border/frame with rounded corners and corner lines.
class OverlayFramePainter extends CustomPainter {
  OverlayFramePainter({
    required this.paintColor,
    this.borderThickness = 2,
    this.borderRadius = 20,
  });

  final Color paintColor;
  final double borderThickness;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = paintColor
      ..strokeWidth = borderThickness
      ..style = PaintingStyle.stroke;

    final radius = borderRadius;
    final cornerLength = 15 + borderThickness;

    _drawTopLeft(canvas, paint, radius, cornerLength);
    _drawTopRight(canvas, paint, size, radius, cornerLength);
    _drawBottomLeft(canvas, paint, size, radius, cornerLength);
    _drawBottomRight(canvas, paint, size, radius, cornerLength);
  }

  void _drawTopLeft(Canvas canvas, Paint paint, double radius, double length) {
    final path = Path();
    path.moveTo(0, radius + length);
    path.lineTo(0, radius);
    path.arcToPoint(Offset(radius, 0), radius: Radius.circular(radius));
    path.lineTo(radius + length, 0);
    canvas.drawPath(path, paint);
  }

  void _drawTopRight(
    Canvas canvas,
    Paint paint,
    Size size,
    double radius,
    double length,
  ) {
    final path = Path();
    path.moveTo(size.width - radius - length, 0);
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(
      Offset(size.width, radius),
      radius: Radius.circular(radius),
    );
    path.lineTo(size.width, radius + length);
    canvas.drawPath(path, paint);
  }

  void _drawBottomLeft(
    Canvas canvas,
    Paint paint,
    Size size,
    double radius,
    double length,
  ) {
    final path = Path();
    path.moveTo(radius + length, size.height);
    path.lineTo(radius, size.height);
    path.arcToPoint(
      Offset(0, size.height - radius),
      radius: Radius.circular(radius),
    );
    path.lineTo(0, size.height - radius - length);
    canvas.drawPath(path, paint);
  }

  void _drawBottomRight(
    Canvas canvas,
    Paint paint,
    Size size,
    double radius,
    double length,
  ) {
    final path = Path();
    path.moveTo(size.width, size.height - radius - length);
    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(
      Offset(size.width - radius, size.height),
      radius: Radius.circular(radius),
    );
    path.lineTo(size.width - radius - length, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
