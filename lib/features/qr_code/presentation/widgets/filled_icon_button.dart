import 'package:flutter/material.dart';

class FilledIconButton extends StatelessWidget {
  const FilledIconButton({
    super.key,
    required this.onPressed,
    required this.iconData,
    this.backgroundColor,
    this.foregroungColor = Colors.white,
    this.radiusSize,
  });
  final VoidCallback onPressed;
  final IconData iconData;
  final Color? backgroundColor;
  final Color foregroungColor;
  final double? radiusSize;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radiusSize,
      backgroundColor: backgroundColor ?? Colors.grey.shade200.withOpacity(0.2),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          iconData,
          color: foregroungColor,
          textDirection: TextDirection.ltr,
        ),
      ),
    );
  }
}
