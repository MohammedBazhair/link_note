import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/assets/app_images.dart';
import '../controllers/auth_controller.dart';

class SignGoogleButton extends ConsumerWidget {
  const SignGoogleButton({super.key});

  @override
  Widget build(BuildContext context,ref) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xEADAFFFC),
        foregroundColor: Colors.black,
      ),
      onPressed: ()async {
       await ref.read(authProvider.notifier).loginWithGoogle();
      },
      label: const Text('Continue with Google'),
      icon: Image.asset(Assets.imagesGoogle, height: 24),
    );
  }
}
