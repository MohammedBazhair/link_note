import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/styles_consts.dart';
import '../../domain/entities/note.dart';
import 'note_tile.dart';

class NotesListView extends StatelessWidget {
  const NotesListView({
    super.key,
    required this.notes,
    this.isShimmerEnabled = false,
  });
  final List<Note> notes;
  final bool isShimmerEnabled;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isShimmerEnabled,
      effect: StylesConsts.shimmerEffect,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteTile(note);
        },
        separatorBuilder: (_, __) => const SizedBox(height: 10),
      ),
    );
  }
}
