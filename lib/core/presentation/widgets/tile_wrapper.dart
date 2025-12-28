import 'package:flutter/material.dart';

import '../../constants/colors/colors.dart';

class TileWrapper extends StatelessWidget {
  const TileWrapper({super.key, required this.child});
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DarkColors.primary.withOpacity(.08),
            DarkColors.primary.withOpacity(.12),
          ],
          stops: const [0.4, 0.8],
        ),
        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: DarkColors.primary.withOpacity(0.2),
          strokeAlign: BorderSide.strokeAlignCenter,
          width: 0.4,
        ),
      ),
      child: child,
    );
  }
}
