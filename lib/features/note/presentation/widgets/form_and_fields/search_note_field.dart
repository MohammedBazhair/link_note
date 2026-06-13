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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: SearchBar(
        controller: _controller,
        hintText: 'بحث...',
        textInputAction: TextInputAction.search,
        autoFocus: true,
        onTapOutside: (_) {
          ref.read(searchNoteControllerProvider.notifier).closeSearchMode();
        },
        leading: const Icon(Icons.search, color: Color(0xFF95B5B7)),

        onChanged: ref.read(searchNoteControllerProvider.notifier).search,
        trailing: [
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return child!;
            },
            child: IconButton(
              color: const Color(0xFF95B5B7),
              iconSize: 20,
              onPressed: _controller.clear,
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}
