import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/internal_constants/log.dart';
import '../../../../qr_code/domain/entities/qr_data.dart';
import '../../../domain/entities/editor_content.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/entities/note_controllers.dart';
import '../note_providers.dart';
import 'current_note_state.dart';

class CurrentNoteController extends Notifier<CurrentNoteState> {
  @override
  CurrentNoteState build() => CurrentNoteState();

  NoteFormControllers get form => ref.read(noteFormProvider);

  void loadNote({Note? note,  CurrentNoteFunctionality ?functionality}) {
    state = state.copyWith(note: note, currentNoteFunctionality: functionality);

    if (note == null) return;

    form.title.text = note.title;
    form.content.text = note.content;

    final editorContent = EditorContent(
      title: note.title,
      content: note.content,
    );

    ref.read(editorControllerProvider.notifier).loadContent(editorContent);
  }

  void replaceNote(Note note) {
    if (state.note?.updatedAt == note.updatedAt) return;

    state = state.copyWith(note: note);
    form.syncWith(note);
  }

  QrData generateQrData() {
    final currentNote = state.note;
    if (currentNote == null) {
      throw Exception('No note to generate QR data from');
    }

    return QrData(name: currentNote.title, qrCodeRaw: currentNote.toJson());
  }

  Future<bool> deleteNote() async {
    try {
      final currentNote = state.note;

      if (currentNote == null) throw Exception('No note to delete');

      await ref.read(noteControllerProvider.notifier).deleteNote(currentNote);
      return true;
    } catch (e, st) {
      Logger.log(error: e, stackTrace: st);
      return false;
    }
  }
}
