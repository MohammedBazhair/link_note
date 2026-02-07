import 'package:flutter/material.dart';

class TailMessagePaint extends CustomPainter {
  TailMessagePaint({
    super.repaint,
    required this.isMe,
    required this.color,
    required this.textDirection,
  });

  final bool isMe;

  final Color color;
  final TextDirection textDirection;

  bool get isRtl => textDirection == TextDirection.rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();

    const tailSize = Size(10, 7);

    if (isRtl ? isMe : !isMe) {
      path.moveTo(size.width, size.height);
      path.lineTo(size.width + tailSize.width, size.height);
      path.lineTo(size.width, size.height - tailSize.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(-tailSize.width, size.height);
      path.lineTo(0, size.height - tailSize.height);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
