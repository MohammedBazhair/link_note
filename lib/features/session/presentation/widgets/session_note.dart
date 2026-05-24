import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/presentation/widgets/conditional_builder.dart';
import '../../../note/domain/entities/note.dart';
import '../../../note/presentation/controllers/note_providers.dart';
import '../../../note/presentation/widgets/content_form_field.dart';
import '../../../note/presentation/widgets/title_form_field.dart';
import '../../injection.dart';
import '../controllers/session_providers.dart';

class SessionNoteEditor extends ConsumerStatefulWidget {
  const SessionNoteEditor({super.key});

  @override
  ConsumerState<SessionNoteEditor> createState() => _SessionNoteEditorState();
}

class _SessionNoteEditorState extends ConsumerState<SessionNoteEditor> {
  Timer? _updateDebounceTimer;

  void scheduleNoteUpdate() {
    _updateDebounceTimer?.cancel();
    _updateDebounceTimer = Timer(const Duration(seconds: 2), () {
      if (currentEditedNote == null) return;
      ref.read(noteControllerProvider.notifier).updateNote(currentEditedNote!);
    });
  }

  Note? get currentEditedNote => ref.read(currentNoteControllerProvider).note;

  @override
  void dispose() {
    _updateDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedNoteId = ref.watch(sessionProvider)?.noteId;

    if (selectedNoteId == null) {
      return const Center(child: Text('لاتوجد ملاحظة محددة'));
    }

    final noteStreamAsync = ref.watch(singleNoteStreamProvider(selectedNoteId));

    return noteStreamAsync.when(
      data: (note) {
        return ConditionalBuilder(
          condition: note != null,
          builder: (_) => SessionNoteForm(onNoteChanged: scheduleNoteUpdate),
          fallback: (_) => const Center(child: Text('لا يوجد ملاحظة')),
        );
      },
      loading: () => const Skeletonizer(child: SessionNoteForm()),
      error: (error, stackTrace) => const Center(
        child: Text('حدثت مشكلة منعت المشاركة تاكد من الاتصال بالنت'),
      ),
    );
  }
}

class SessionNoteForm extends ConsumerWidget {
  const SessionNoteForm({super.key, this.onNoteChanged});
  final VoidCallback? onNoteChanged;

  @override
  Widget build(BuildContext context, ref) {
    final isHost = ref.watch(
      sessionControllerProvider.select((s) => s.currentMember?.isHost ?? false),
    );

    return Column(
      spacing: 16,
      children: [
        TitleFormField(readOnly: !isHost),

        Expanded(
          child: ContentFormField(
            readOnly: !isHost,
            onChanged: () => onNoteChanged?.call(),
          ),
        ),
      ],
    );
  }
}
