import 'package:flutter/material.dart';

class ConditionalBuilder extends StatelessWidget {
  const ConditionalBuilder({
    super.key,
    required this.condition,
    required this.builder,
    required this.fallback,
    this.duration = Durations.medium2,
    this.reverseDuration = Durations.medium2,
  });

  final bool condition;

  final WidgetBuilder builder;

  final WidgetBuilder fallback;

  final Duration duration;
  final Duration reverseDuration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      reverseDuration: reverseDuration,
      child: condition ? builder(context) : fallback(context),
    );
  }
}
