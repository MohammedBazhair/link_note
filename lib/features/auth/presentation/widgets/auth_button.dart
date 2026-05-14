import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/custom_progress_widget.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';

class AuthButton extends ConsumerWidget {
  const AuthButton({super.key, required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, ref) {
    final isLoading = ref.watch(authControllerProvider) is AuthLoadingState;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading ? const CustomProgressWidget() : Text(text),
    );
  }
}
