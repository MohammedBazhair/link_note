import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/colors/colors.dart';
import '../../../../core/extensions/extensions.dart';
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
    final isMobile = context.isMobile;
    return Skeletonizer(
      enabled: isShimmerEnabled,
      effect: StylesConsts.shimmerEffect,
      child: RefreshIndicator(
        color: DarkColors.primary,
        onRefresh: ref.read(noteControllerProvider.notifier).syncNotes,
        child: MasonryGridView.builder(
          padding: const EdgeInsets.all(24),
          physics: const AlwaysScrollableScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          itemCount: notes.length,

          itemBuilder: (context, index) {
            final note = notes[index];
            return NoteTile(note: note);
          },
          mainAxisSpacing:isMobile?5: 15,
          crossAxisSpacing:isMobile?5: 15,
          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 2 : 3,
          ),
        ),
      ),
    );
  }
}
