import 'package:flutter/material.dart';
import '../../constants/colors/colors.dart';

class CenteredDividerText extends StatelessWidget {
  const CenteredDividerText({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          const SizedBox(width: 15),
          Text(
            text,
            style: const TextStyle(
              color: DarkColors.secondFont,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}
