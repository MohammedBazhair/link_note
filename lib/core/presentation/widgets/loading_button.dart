import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainButton extends ConsumerWidget {
  const MainButton({super.key, required this.onPressed, required this.text});
  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(onPressed: onPressed, child: Text(text));
  }
}
