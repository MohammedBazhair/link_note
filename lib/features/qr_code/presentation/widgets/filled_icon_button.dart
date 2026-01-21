import 'package:flutter/material.dart';

class FilledIconButton extends StatelessWidget {
  const FilledIconButton({
    super.key,
    required this.onPressed,
    required this.iconData,
    this.backgroundColor,
    this.foregroungColor = Colors.white,
  });
  final VoidCallback onPressed;
  final IconData iconData;
  final Color? backgroundColor;
  final Color foregroungColor;
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: backgroundColor ?? Colors.grey.shade200.withOpacity(0.5),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(iconData, color: foregroungColor, size: 24),
      ),
    );
  }
}
