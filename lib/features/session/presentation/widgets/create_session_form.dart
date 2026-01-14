import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/widgets/loading_button.dart';
import '../../../note/presentation/screens/notes_list_screen.dart';
import '../../../note/presentation/widgets/note_tile.dart';
import 'selected_note.dart';

class CreateSessionForm extends ConsumerWidget {
  const CreateSessionForm({super.key, required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context, ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 15,
      children: [
        const Text('إنشاء جلسة تعاون لمشاركة وتحرير الملاحظات'),
        ElevatedButton(
          onPressed: () async {
            ref
                .read(selectableNoteProvider.notifier)
                .update((s) => s.copyWith(isSelectable: true));
            await context.pushTo(const NotesListScreen());
          },
          child: const Text('اختر ملاحظة'),
        ),
        const SizedBox(height: 16),
        const SelectedNote(),
        const SizedBox(height: 15),
        MainButton(onPressed: onCreate, text: 'إنشاء الجلسة'),
      ],
    );
  }
}
