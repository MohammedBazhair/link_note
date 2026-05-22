import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/constants/colors/colors.dart';

// TODO: Completed Logic of this button to enable it only when there are changes and show a loading state when saving
final hasChangesProvider = StateProvider.autoDispose<bool>((_) => false);

class SaveNoteButton extends ConsumerWidget {
  const SaveNoteButton({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final hasChanges = ref.watch(hasChangesProvider);

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E2230),
        foregroundColor: hasChanges ? DarkColors.secondFont : Colors.white,
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
