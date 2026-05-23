import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/internal_constants/log.dart';
import '../../../../qr_code/domain/entities/qr_data.dart';
import '../../../domain/entities/editor_content.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/entities/note_controllers.dart';
import '../note_providers.dart';

class EditorFormController extends Notifier<Note?> {
  @override
  Note? build() => null;

  NoteFormControllers get form => ref.read(noteFormProvider);

  void initForm([Note? note]) {
    if (note == null) return _clearForm();

    state = note.copyWith();
    form.title.text = note.title;
    form.content.text = note.content;

    final editorContent = EditorContent(
      title: note.title,
      content: note.content,
    );
    
    ref
        .read(editorHistoryControllerProvider.notifier)
        .initContent(editorContent);
  }

  void _clearForm() {
    form.clearControllers();
    state = null;
  }

  void syncWith(Note note) {
    if (state?.updatedAt == note.updatedAt) return;

    state = note;
    form.syncWith(note);
  }

  QrData generateQrData() {
    if (state == null) throw Exception('No note to generate QR data from');

    return QrData(name: state!.title, qrCodeRaw: state!.toJson());
  }

  Future<bool> deleteNote() async {
    try {
      if (state == null) throw Exception('No note to delete');

      await ref.read(noteControllerProvider.notifier).deleteNote(state!);
      return true;
    } catch (e, st) {
      Logger.log(error: e, stackTrace: st);
      return false;
    }
  }
}
