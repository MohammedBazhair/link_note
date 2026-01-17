import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/user/presentation/controllers/user_controller.dart';
import '../../constants/colors/colors.dart';

class CreditsWidget extends StatelessWidget {
  const CreditsWidget({super.key});

  @override
  Widget build(BuildContext context,) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: DarkColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
      ),
    
      child: Row(
        spacing: 5,
        children: [
          const Icon(Icons.flash_on, size: 16),
          Consumer(
            builder: (_,ref,_) {
        final credits = ref.watch(
          userControllerProvider.select((p) => p.profile.credits),
        );
              return Text('$credits', style: const TextStyle(fontSize: 12));
            },
          ),
        ],
      ),
    );
  }
}
