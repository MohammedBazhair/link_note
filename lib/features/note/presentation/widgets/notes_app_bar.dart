import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/features/note/presentation/widgets/form_and_fields/search_note_field.dart';
import 'package:link_note/features/note/presentation/widgets/notes_contextual_action_bar/notes_contextual_action_bar.dart';
import '../../../../core/constants/colors/colors.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/widgets/conditional_builder.dart';
import '../controllers/note_providers.dart';

class NotesAppBar extends ConsumerWidget {
  const NotesAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isContextualMode = ref.watch(
      notesContextualActionBarController.select((s) => s.actionBarOpened),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: ConditionalBuilder(
          condition: isContextualMode,
          builder: (_) => const NotesContextualActionBar(),
          fallback: (_) => const _NotesDefaultAppBar(),
        ),
      ),
    );
  }
}

class _NotesDefaultAppBar extends ConsumerWidget {
  const _NotesDefaultAppBar();

  @override
  Widget build(BuildContext context, ref) {
    final isSelectable = ref.watch(
      selectableNoteProvider.select((s) => s.isSelectable),
    );

    final isSearchMode = ref.watch(
      searchNoteControllerProvider.select((s) => s.isSearchMode),
    );

    return Row(
      children: [
        isSelectable
            ? TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: DarkColors.primary,
                  overlayColor: Colors.transparent,
                ),
                label: const Text('تم'),
                onPressed: context.pop,
                icon: const Icon(Icons.check),
              )
            : ConditionalBuilder(
                condition: !isSearchMode,
                builder: (_) => IconButton(
                  onPressed: ref
                      .read(searchNoteControllerProvider.notifier)
                      .enableSearchMode,
                  icon: const Icon(Icons.search),
                ),
                fallback: (_) => const SizedBox.shrink(),
              ),

        Expanded(
          child: ConditionalBuilder(
            duration: Durations.short1,
            condition: isSearchMode,
            builder: (_) =>
                const SearchNoteField(key: ValueKey('SearchNoteField')),
            fallback: (_) => isSelectable
                ? const Text(
                    'حدد ملاحظة',
                    key: ValueKey('title1'),
                    textAlign: TextAlign.center,
                  )
                : const Text(
                    'الملاحظات',
                    key: ValueKey('title2'),

                    textAlign: TextAlign.center,
                  ),
          ),
        ),

        isSelectable
            ? const SizedBox(width: 50)
            : IconButton(
                onPressed: Scaffold.of(context).openDrawer,
                icon: const Icon(Icons.menu_rounded),
              ),
      ],
    );
  }
}
