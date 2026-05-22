import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors/colors.dart';
import '../controllers/note_providers.dart';

class SaveNoteButton extends ConsumerWidget {
  const SaveNoteButton({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final hasChanges = ref.watch(
      editorFormControllerProvider.select((s) => s.hasChanges),
    );

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: DarkColors.primary.withOpacity(0.15),
        foregroundColor: hasChanges ? Colors.white : DarkColors.secondFont,
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        fixedSize: const Size.fromHeight(20),
      ),
      onPressed: hasChanges ? () {} : null,
      icon: const Icon(Icons.save_rounded),
      label: hasChanges ? const Text('حفظ') : const Text('تم الحفظ'),
    );
  }
}
