import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/presentation/widgets/conditional_builder.dart';
import '../../../note/domain/entities/note.dart';
import '../../../note/presentation/controllers/note_controller/note_controller.dart';
import '../../../note/presentation/controllers/note_providers.dart';
import '../../../note/presentation/widgets/content_form_field.dart';
import '../../../note/presentation/widgets/title_form_field.dart';
import '../controllers/session_controller.dart';
import '../controllers/session_providers.dart';

class SessionNote extends ConsumerStatefulWidget {
  const SessionNote({super.key});

  @override
  ConsumerState<SessionNote> createState() => _SessionBodyState();
}

class _SessionBodyState extends ConsumerState<SessionNote> {
  Timer? _debounce;

  void updateNoteDebounced() {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(seconds: 2),
      () => ref.read(noteControllerProvider.notifier).updateNote(updatedNote),
    );
  }

  Note get updatedNote => ref.watch(editorFormProvider).note;

  @override
  void dispose() {
    _debounce?.cancel();
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
          builder: (_) => SessionNoteForm(onUpdatedNote: updateNoteDebounced),
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
  const SessionNoteForm({super.key, this.onUpdatedNote});
  final VoidCallback? onUpdatedNote;

  @override
  Widget build(BuildContext context, ref) {
    final formState = ref.watch(editorFormProvider);
    final isHost = ref.watch(
      sessionControllerProvider.select((s) => s.currentMember?.isHost ?? false),
    );

    return Column(
      spacing: 16,
      children: [
        TitleFormField(
          controller: formState.titleController,
          readOnly: !isHost,
          onChanged: (_) => onUpdatedNote?.call(),
        ),

        Expanded(
          child: ContentFormField(
            controller: formState.contentController,
            readOnly: !isHost,
            onChanged: (_) => onUpdatedNote?.call(),
          ),
        ),
      ],
    );
  }
}
