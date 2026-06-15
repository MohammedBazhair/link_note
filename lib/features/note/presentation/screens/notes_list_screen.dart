import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/core/extensions/extensions.dart';
import 'package:link_note/core/models/snack_bar_action_model.dart';
import 'package:link_note/core/presentation/providers/core_providers.dart';
import 'package:link_note/core/presentation/widgets/custom_drawer.dart';
import 'package:link_note/core/presentation/widgets/floating_actions_buttons.dart';
import 'package:link_note/features/note/presentation/controllers/note_providers.dart';
import 'package:link_note/features/note/presentation/controllers/notes_contextual_action_bar_controller/notes_contextual_action_bar_state.dart';
import 'package:link_note/features/note/presentation/widgets/notes_app_bar.dart';
import 'package:link_note/features/note/presentation/widgets/notes_list_body.dart';

class NotesListScreen extends ConsumerStatefulWidget {
  const NotesListScreen({super.key});
  @override
  ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends ConsumerState<NotesListScreen> {
  @override
  void initState() {
    super.initState();
    listenContextualAppBar();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await ref.read(userControllerProvider.notifier).loadProfile();

      if (!mounted) return;
      await ref.read(noteControllerProvider.notifier).syncNotes();

      if (!mounted) return;
      ref.read(isInNotesListScreen.notifier).update((_) => true);
    });
  }

  void listenContextualAppBar() {
    ref.listenManual(notesContextualActionBarController, (_, state) {
      final successMessage = state.successMessage;
      final errorMessage = state.errorMessage;

      if (errorMessage != null) {
        context.showSnakbar(errorMessage);
      }

      switch (state.currentAction) {
        case NotesContextualAppBarAction.deleteNotes:
          context.showSnakbar(
            successMessage!,
            action: SnackBarActionModel(
              label: 'تراجع',
              onPressed: ref
                  .read(notesContextualActionBarController.notifier)
                  .undoDeleteNotes,
            ),
          );
          return;
        case null:
      }

      if (successMessage != null) {
        context.showSnakbar(successMessage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ref.read(isFloatingActiosClicked.notifier).state = false,
      child: Scaffold(
        key: widget.key,
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight + 5),
          child: NotesAppBar(),
        ),
        drawer: const CustomDrawer(),
        floatingActionButton: const FloatingActionsButtons(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: const NotesListBody(),
      ),
    );
  }
}
