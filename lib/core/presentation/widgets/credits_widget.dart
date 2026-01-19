import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../features/note/presentation/controllers/note_ai_controller/note_ai_state.dart';
import '../../../features/note/presentation/controllers/note_providers.dart';
import '../../constants/colors/colors.dart';
import '../../extensions/extensions.dart';

class CreditsWidget extends ConsumerWidget {
  const CreditsWidget({super.key});

  @override
  Widget build(BuildContext context, ref) {
    ref.listen(noteAiNotiferProvider, (_, state) {
      switch (state) {
        case ShowMessageAiNoteState(:final message):
          context.showSnakbar(message);

        case SuccessAiNoteState():
          // تحديث الـ credits بعد نجاح العملية وتحديثها في الـ database
          ref.invalidate(getCreditsProvider);
        case UpdatingAiNoteState():
        case ResetAiNoteState():
      }
    });
    final creditsAsync = ref.watch(getCreditsProvider);

    return creditsAsync.when(
      data: (credits) {
        return _CreditsBody(credits);
      },
      loading: () {
        return const Skeletonizer(child: _CreditsBody(0));
      },
      error: (error, stackTrace) {
        return const SizedBox.shrink();
      },
    );
  }
}

class _CreditsBody extends StatelessWidget {
  const _CreditsBody(this.credits);
  final int credits;

  @override
  Widget build(BuildContext context) {
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
          Text('$credits', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
