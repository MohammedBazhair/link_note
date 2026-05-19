import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/colors/colors.dart';
import '../../../../core/theme/styles_consts.dart';
import '../../domain/entities/note.dart';
import '../controllers/note_providers.dart';
import 'note_tile.dart';

class NotesListView extends ConsumerWidget {
  const NotesListView({
    super.key,
    required this.notes,
    this.isShimmerEnabled = false,
  });
  final List<Note> notes;
  final bool isShimmerEnabled;

  @override
  Widget build(BuildContext context, ref) {
    return Skeletonizer(
      enabled: isShimmerEnabled,
      effect: StylesConsts.shimmerEffect,
      child: RefreshIndicator(
        color: DarkColors.primary,
        onRefresh: ref.read(noteControllerProvider.notifier).syncNotes,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.all(24),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return NoteTile(note);
          },
          separatorBuilder: (_, __) => const SizedBox(height: 5),
        ),
      ),
    );
  }
}
