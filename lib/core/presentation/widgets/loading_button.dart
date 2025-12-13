import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final loadingProvider = StateProvider.autoDispose((ref) => false);

class LoadingButton extends ConsumerWidget {
  const LoadingButton({super.key, required this.onPressed, required this.text});
  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loadingProvider);

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading ? const CustomProgressWidget() : Text(text),
    );
  }
}

class CustomProgressWidget extends StatelessWidget {
  const CustomProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 27,
      width: 27,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
