import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/internal_constants/typedef.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/widgets/custom_drawer.dart';
import '../../../../core/presentation/widgets/floating_actions_buttons.dart';
import '../../../../core/theme/styles_consts.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import '../../domain/entities/note.dart';
import '../controllers/note_controller.dart';
import '../widgets/note_tile.dart';
import '../widgets/nothing_note.dart';

class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final height = MediaQuery.of(context).size.height * 0.8;
    final userId = ref.read(userControllerProvider).profile.userId;
    final isSelectable = ref.watch(
      selectableNoteProvider.select((s) => s.isSelectable),
    );
    return Scaffold(
      appBar: AppBar(
        title: isSelectable ? const Text('Select a Note') : const Text('Notes'),
        leading: isSelectable
            ? TextButton.icon(
                label: const Text('Done'),
                onPressed: context.pop,
                icon: const Icon(Icons.check),
              )
            : null,
      ),
      drawer: isSelectable ? null : const CustomDrawer(),
      floatingActionButton: isSelectable
          ? null
          : const FloatingActionsButtons(),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: StreamBuilder<RowList>(
          stream:
              ref
                      .read(noteControllerProvider.notifier)
                      .fetchNotesRealTime(userId)
                  as Stream<RowList>,
          builder: (context, snapshot) {
            final notes = snapshot.data?.map(Note.fromMap).toSet() ?? {};
            final fakeNotes = List.generate(
              7,
              (_) => Note(
                title: 'titletsg',
                content:
                    'content content content content content content content.',
              ),
            );
            final enabledFake =
                snapshot.connectionState == ConnectionState.waiting;

            if (snapshot.connectionState != ConnectionState.waiting &&
                !snapshot.hasData) {
              return NothingNoteWidget(height: height);
            }

           

            return Skeletonizer(
              enabled: enabledFake,
              effect: StylesConsts.shimmerEffect,
              child: ListView.separated(
                itemCount: enabledFake ? fakeNotes.length : notes.length,
                itemBuilder: (context, index) {
                  final note = enabledFake
                      ? fakeNotes[index]
                      : notes.elementAt(index);
                  return NoteTile(note);
                },
                separatorBuilder: (_, __) => const SizedBox(height: 10),
              ),
            );
          },
        ),
      ),
    );
  }
}
