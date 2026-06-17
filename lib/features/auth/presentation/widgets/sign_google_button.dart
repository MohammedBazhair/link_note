import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_note/core/presentation/widgets/loading_widget.dart';

import '../../../../core/constants/assets/app_assets.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';

class SignGoogleButton extends ConsumerWidget {
  const SignGoogleButton({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final state = ref.watch(authControllerProvider);
    final loadingState = state is AuthLoadingState ? state : null;
    final isLoading =
        loadingState?.authLoadingType == AuthLoadingType.signWithGoogle;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xEAFFFFFF).withOpacity(0.9),
        foregroundColor: Colors.black,
      ),
      onPressed: isLoading
          ? null
          : ref.read(authControllerProvider.notifier).loginWithGoogle,
      label: const Text('المتابعة عبر Google'),
      icon: isLoading
          ? const LoadingWidget(size: 20)
          : SvgPicture.asset(Assets.iconsGoogle, width: 24),
    );
  }
}
