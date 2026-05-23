import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/internal_constants/log.dart';
import '../../../../qr_code/domain/entities/qr_data.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/entities/note_controllers.dart';
import '../note_providers.dart';
import 'editor_form_state.dart';

class EditorFormController extends Notifier<EditorFormState> {
  @override
  EditorFormState build() {
    return EditorFormState();
  }

  NoteFormControllers get form => ref.watch(noteFormProvider);

  void initForm([Note? note]) {
    if (note == null) return _clearForm();

    state = state.copyWith(note: note);
    form.title.text = note.title;
    form.content.text = note.content;
  }

  void _clearForm() {
    form.clearControllers();
    state = EditorFormState();
  }

  void syncWith(Note note) {
    if (state.note?.updatedAt == note.updatedAt) return;

    state = state.copyWith(note: note);
    form.syncWith(note);
  }

  QrData generateQrData() {
    if (state.note == null) throw Exception('No note to generate QR data from');

    return QrData(name: state.note!.title, qrCodeRaw: state.note!.toJson());
  }

  Future<bool> deleteNote() async {
    try {
      if (state.note == null) throw Exception('No note to delete');

      await ref.read(noteControllerProvider.notifier).deleteNote(state.note!);
      return true;
    } catch (e, st) {
      Logger.log(error: e, stackTrace: st);
      return false;
    }
  }
}
