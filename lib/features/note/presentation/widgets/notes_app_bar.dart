import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            : IconButton(onPressed: () {}, icon: const Icon(Icons.search)),

        isSelectable ? const Text('حدد ملاحظة') : const Text('الملاحظات'),

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
