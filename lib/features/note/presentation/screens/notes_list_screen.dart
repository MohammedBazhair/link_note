import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/core/extensions/extensions.dart';
import 'package:link_note/core/models/snack_bar_action_model.dart';
import 'package:link_note/features/note/presentation/controllers/notes_contextual_action_bar_controller/notes_contextual_action_bar_state.dart';
import 'package:link_note/features/note/presentation/widgets/notes_app_bar.dart';
import '../../../../core/presentation/providers/core_providers.dart';
import '../../../../core/presentation/widgets/conditional_builder.dart';
import '../../../../core/presentation/widgets/custom_drawer.dart';
import '../../../../core/presentation/widgets/floating_actions_buttons.dart';
import '../../domain/entities/note.dart';
import '../controllers/note_providers.dart';
import '../widgets/notes_widget.dart';
import '../widgets/nothing_note.dart';

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
      await ref.read(userControllerProvider.notifier).loadProfile();
      await ref.read(noteControllerProvider.notifier).syncNotes();
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
        body: const NotesStreamBuilder(),
      ),
    );
  }
}

class NotesStreamBuilder extends ConsumerWidget {
  const NotesStreamBuilder({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final notesAsync = ref.watch(noteControllerProvider);

    return notesAsync.when(
      data: (notes) {
        return ConditionalBuilder(
          condition: notes.isNotEmpty,
          builder: (_) => NotesListView(notes: notes),
          fallback: (_) => const NothingNoteWidget(),
        );
      },
      loading: () {
        final fakeNotes = List.generate(8, (index) => Note.fake());
        return NotesListView(notes: fakeNotes, isShimmerEnabled: true);
      },

      error: (error, stackTrace) {
        return const Center(child: Text('حدث خطأ ما'));
      },
    );
  }
}
