import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../note/domain/entities/note.dart';
import '../../../note/presentation/controllers/note_controller/note_controller.dart';
import '../../../note/presentation/controllers/providers.dart';
import '../../../note/presentation/widgets/editor_form.dart';
import '../controllers/session_controller.dart';
import '../widgets/session_body.dart';
import '../widgets/session_popup_menu.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  Timer? _debounce;


  void updateNoteDebounced(Note note) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(seconds: 2),
      () => ref.read(noteControllerProvider.notifier).updateNote(note),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider).session;
    final noteId = session?.noteId;

    if (noteId == null) {
      return const Scaffold(
        body: Center(child: Text('لا توجد ملاحظة مرتبطة بهذه الجلسة')),
      );
    }

    
    ref.listen<AsyncValue<Note?>>(singleNoteStreamProvider(noteId), (
      previous,
      next,
    ) {
      next.whenData((note) {
        if (note != null) {
          ref.read(editorFormProvider).syncWith(note);
        }
      });
    });

    final noteAsync = ref.watch(singleNoteStreamProvider(noteId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('عنوان الجلسة'),
        actions: const [SessionPopupMenu()],
      ),
      body: noteAsync.when(
        data: (note) {
          if (note == null) {
            return const Center(child: Text('الملاحظة غير موجودة'));
          }

          // ⬅ هنا نغذي الفورم
          ref.read(editorFormProvider).syncWith(note);

          return SessionBody(note: note);
        },
        loading: () {
          return const Center(
            child: SizedBox(
              width: 25,

              height: 25,
              child: CircularProgressIndicator(),
            ),
          );
        },

        error: (_, _) => const Center(child: Text('خطأ')),
      ),
    );
  }
}
