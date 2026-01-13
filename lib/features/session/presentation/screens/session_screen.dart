import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  @override
  void initState() {
    super.initState();

    final session = ref.read(sessionControllerProvider).session;
    final noteId = session?.noteId;

    if (noteId != null) {
      // استماع مستمر للـ stream
      ref.listenManual(singleNoteStreamProvider(noteId), (previous, next) {
        next.whenData((note) {
          if (note != null) {
            // مزامنة الفورم مع أحدث بيانات
            ref.read(editorFormProvider).syncWith(note);
          }
        });
      });
    }
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
          ref.read(editorFormProvider).syncWith(note);
          return const SessionBody();
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
