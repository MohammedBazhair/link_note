import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/core/constants/colors/colors.dart';
import 'package:link_note/features/note/note_ai_listener.dart';
import 'package:link_note/features/note/presentation/controllers/note_providers.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CreditsWidget extends ConsumerWidget {
  const CreditsWidget({super.key});

  @override
  Widget build(BuildContext context, ref) {
    ref.listen(noteAiNotiferProvider, (_, state) {
      noteAiListener(context: context, state: state, ref: ref);
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
        return const _CreditsBody(0);
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: DarkColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        spacing: 5,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.flash_on, size: 14),
          Text(
            '$credits',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
