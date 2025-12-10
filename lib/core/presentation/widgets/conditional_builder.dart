import 'package:flutter/material.dart';

class ConditionalBuilder extends StatelessWidget {
  const ConditionalBuilder({
    super.key,
    required this.condition,
    required this.builder,
    required this.fallback,
  });

  final bool condition;

  final WidgetBuilder builder;

  final WidgetBuilder fallback;

  @override
  Widget build(BuildContext context) {
    return condition ? builder(context) : fallback(context);
  }
}
