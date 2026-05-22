import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/internal_constants/log.dart';
import '../../../../qr_code/domain/entities/qr_data.dart';
import '../../../domain/entities/note.dart';
import '../note_providers.dart';
import 'editor_form_state.dart';

class EditorFormController extends Notifier<EditorFormState> {
  late final GlobalKey<FormState> formKey;
  late final TextEditingController titleController;
  late final TextEditingController contentController;

  @override
  EditorFormState build() {
    formKey = GlobalKey<FormState>();
    titleController = TextEditingController();
    contentController = TextEditingController();

    titleController.addListener(_titleListener);
    contentController.addListener(_contentListener);

    ref.onDispose(_dispose);
    return EditorFormState();
  }

  void _titleListener() {
    state = state.copyWith(
      hasChanges: true,
      note: state.note?.copyWith(title: titleController.text),
    );
  }

  void _contentListener() {
    state = state.copyWith(
      hasChanges: true,
      note: state.note?.copyWith(content: contentController.text),
    );
  }



  void initForm([Note? note]) {
    if (note == null) return _clearForm();

    titleController.text = note.title;
    contentController.text = note.content;
  }

  void _clearForm() {
    titleController.clear();
    contentController.clear();

    state = EditorFormState();
  }

  void _dispose() {
    titleController.dispose();
    contentController.dispose();
  }

  void syncWith(Note note) {
    if (state.note?.updatedAt == note.updatedAt) return;

    state = state.copyWith(note: note);
    titleController.text = note.title;
    contentController.text = note.content;
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
