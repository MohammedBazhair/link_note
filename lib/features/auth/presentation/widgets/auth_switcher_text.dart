import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';

class AuthSwitcherText extends StatelessWidget {
  const AuthSwitcherText({
    super.key,
    required this.text,
    required this.actionText,
    required this.builder,
  });

  final String text;
  final String actionText;
  final WidgetBuilder builder;

  void _navigate(BuildContext context) {
    context.pushReplacementTo(builder(context));
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: text,
        children: [
          const TextSpan(text: '  '),
          TextSpan(
            text: actionText,
            recognizer: TapGestureRecognizer()
              ..onTap = () => _navigate(context),
            style: const TextStyle(
              color: Color(0xFF00FFFF),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
