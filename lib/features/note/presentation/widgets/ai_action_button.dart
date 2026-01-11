import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/assets/app_assets.dart';

class AiActionButton extends StatelessWidget {
  const AiActionButton({
    super.key,
    required this.isProcessing,
    required this.onPressed,
  });
  final bool isProcessing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: Container(
        padding: const EdgeInsets.all(13),
        width: 45,
        height: 45,
        child: const CircularProgressIndicator(strokeWidth: 1.2),
      ),
      secondChild: IconButton(
        tooltip: 'استعمال AI للتحسين',
        onPressed: onPressed,
        icon: SvgPicture.asset(Assets.iconsWandStars, width: 24),
      ),
      crossFadeState: isProcessing
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 200),
      sizeCurve: Curves.easeInBack,
    );
  }
}
