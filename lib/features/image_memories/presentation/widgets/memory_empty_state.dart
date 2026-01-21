import 'package:flutter/material.dart';

import '../../../../core/constants/colors/colors.dart';

class MemoryEmptyState extends StatelessWidget {
  const MemoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    DarkColors.primary.withOpacity(0.2),
                    DarkColors.primary.withOpacity(0.06),
                  ],
                ),
                border: Border.all(
                  color: DarkColors.primary.withOpacity(0.2),
                  width: 0.8,
                ),
              ),
              child: const Icon(Icons.photo_library_outlined, size: 42),
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد ذكريات صور بعد',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بإضافة أول ذكرى بالضغط على زر الإضافة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


