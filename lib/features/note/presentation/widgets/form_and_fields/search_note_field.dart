import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/features/note/presentation/controllers/note_providers.dart';

class SearchNoteField extends ConsumerStatefulWidget {
  const SearchNoteField({super.key});

  @override
  ConsumerState<SearchNoteField> createState() => _SearchNoteFieldState();
}

class _SearchNoteFieldState extends ConsumerState<SearchNoteField> {
  final _controller = SearchController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closeSearchMode() {
    ref.read(searchNoteControllerProvider.notifier).closeSearchMode();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: SearchBar(
        controller: _controller,
        hintText: 'بحث...',
        textInputAction: TextInputAction.search,
        autoFocus: true,

        leading: const Icon(Icons.search, color: Color(0xFF95B5B7)),

        onChanged: ref.read(searchNoteControllerProvider.notifier).search,
        trailing: [
          IconButton(
            tooltip: 'إغلاق وضع البحث',
            color: const Color(0xFF95B5B7),
            iconSize: 20,
            onPressed: _closeSearchMode,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
