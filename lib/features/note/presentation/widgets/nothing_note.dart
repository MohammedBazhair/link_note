import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/features/note/presentation/controllers/note_providers.dart';

class NothingNoteWidget extends StatelessWidget {
  const NothingNoteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.info_outlined, size: 130),
          SizedBox(height: 30),
          Text(
            'لاتوجد اي ملاحظات.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13),
          ),
          SizedBox(height: 10),
          Text(
            'قم بإنشاء ملاحظة جديدة بالضغط على زر الإضافة.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class NotesSearchResultEmpty extends ConsumerWidget {
  const NotesSearchResultEmpty({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final query = ref.watch(
      searchNoteControllerProvider.select((s) => s.searchQuery),
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.search_rounded, size: 130),
          const SizedBox(height: 30),
          const Text(
            'لا توجد ملاحظات تحتوي على قيمة البحث:',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 10),
          Text(
            query,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
