import 'package:flutter/material.dart';

class OverlayFramePainter extends CustomPainter {
  const OverlayFramePainter();

  double get _borderRadius => 8.0;
  double get _cornerExtension => 15;

  @override
  void paint(Canvas canvas, Size size) {
    const paintColor = Colors.white;
    const borderThickness = 2.0;

    final paint = Paint()
      ..color = paintColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderThickness;

    _drawTopLeft(canvas, paint);
    _drawTopRight(canvas, paint, size);
    _drawBottomLeft(canvas, paint, size);
    _drawBottomRight(canvas, paint, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  void _drawTopLeft(Canvas canvas, Paint paint) {
    final path = Path();

    path.moveTo(0, _borderRadius + _cornerExtension);
    path.lineTo(0, _borderRadius);
    path.arcToPoint(
      Offset(_borderRadius, 0),
      radius: Radius.circular(_borderRadius),
    );
    path.lineTo(_borderRadius + _cornerExtension, 0);
    canvas.drawPath(path, paint);
  }

  void _drawTopRight(Canvas canvas, Paint paint, Size size) {
    final path = Path();

    path.moveTo(size.width - _borderRadius - _cornerExtension, 0);
    path.lineTo(size.width - _borderRadius, 0);
    path.arcToPoint(
      Offset(size.width, _borderRadius),
      radius: Radius.circular(_borderRadius),
    );
    path.lineTo(size.width, _borderRadius + _cornerExtension);
    canvas.drawPath(path, paint);
  }

  void _drawBottomLeft(Canvas canvas, Paint paint, Size size) {
    final path = Path();

    path.moveTo(0, size.height - _borderRadius - _cornerExtension);
    path.lineTo(0, size.height - _borderRadius);
    path.arcToPoint(
      Offset(_borderRadius, size.height),
      radius: Radius.circular(_borderRadius),
      clockwise: false,
    );
    path.lineTo(_cornerExtension + _borderRadius, size.height);
    canvas.drawPath(path, paint);
  }

  void _drawBottomRight(Canvas canvas, Paint paint, Size size) {
    final path = Path();

    path.moveTo(size.width, size.height - _borderRadius - _cornerExtension);
    path.lineTo(size.width, size.height - _borderRadius);
    path.arcToPoint(
      Offset(size.width - _borderRadius, size.height),
      radius: Radius.circular(_borderRadius),
    );
    path.lineTo(size.width - _cornerExtension - _borderRadius, size.height);
    canvas.drawPath(path, paint);
  }
}
