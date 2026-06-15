import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/features/note/presentation/controllers/note_providers.dart';

class SelectedNotesCounterText extends ConsumerWidget {
  const SelectedNotesCounterText({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final selectedCount = ref
        .watch(
          notesContextualActionBarController.select((s) => s.selectedNotesIds),
        )
        .length;
    return Text('تم اختيار $selectedCount من الملاحظات');
  }
}
