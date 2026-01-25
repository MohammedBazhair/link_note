import 'package:flutter/material.dart';

import 'overlay_frame_painter.dart';
import 'scanner_line_painter.dart';

class ScannerAnimatedBuilder extends StatefulWidget {
  const ScannerAnimatedBuilder({super.key, required this.size});

  final Size size;

  @override
  State<ScannerAnimatedBuilder> createState() => _ScannerAnimatedBuilderState();
}

class _ScannerAnimatedBuilderState extends State<ScannerAnimatedBuilder>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const OverlayFramePainter(),
      foregroundPainter: ScannerLinePainter(animationController),
      size:widget.size,
    );
  }
}
