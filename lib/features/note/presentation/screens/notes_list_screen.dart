import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/providers/provider.dart';
import '../../../../core/presentation/widgets/conditional_builder.dart';
import '../../../../core/presentation/widgets/custom_drawer.dart';
import '../../../../core/presentation/widgets/floating_actions_buttons.dart';
import '../../../../core/theme/styles_consts.dart';
import '../../domain/entities/note.dart';
import '../controllers/providers.dart';
import '../widgets/note_tile.dart';
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
    // للتأكد من تجديد التوكن عند أول اتصال
    ref.read(tokenRefreshProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(isInNotesListScreen.notifier).update((_) => true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: NotesListAppBar(),
      ),
      drawer: CustomDrawer(),
      floatingActionButton: FloatingActionsButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: NotesStreamBuilder(),
    );
  }
}

class NotesListAppBar extends ConsumerWidget {
  const NotesListAppBar({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isSelectable = ref.watch(
      selectableNoteProvider.select((s) => s.isSelectable),
    );

    return AppBar(
      title: isSelectable ? const Text('حدد ملاحظة') : const Text('الملاحظات'),
      leading: isSelectable
          ? TextButton.icon(
              label: const Text('تم'),
              onPressed: context.pop,
              icon: const Icon(Icons.check),
            )
          : null,
      actions: [
        if (!isSelectable && Platform.isWindows)
          IconButton(
            hoverColor: Colors.transparent,

            onPressed: () {
              ref.invalidate(notesStreamProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
      ],
    );
  }
}

class NotesStreamBuilder extends ConsumerWidget {
  const NotesStreamBuilder({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final notesAsync = ref.watch(notesStreamProvider);

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
        return Skeletonizer(
          effect: StylesConsts.shimmerEffect,
          child: NotesListView(notes: fakeNotes),
        );
      },

      error: (error, stackTrace) {
        print(error);
        return const Center(child: Text('حدث خطأ ما'));
      },
    );
  }
}
