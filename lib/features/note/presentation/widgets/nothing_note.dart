import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NothingNoteWidget extends ConsumerWidget {
  const NothingNoteWidget({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return const Center(
      child: Text(
        'لاتوجد اي ملاحظات. \n قم بإنشاء ملاحظة جديدة بالضغط على زر الإضافة.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15, height: 1.8),
      ),
    );
  }
}
