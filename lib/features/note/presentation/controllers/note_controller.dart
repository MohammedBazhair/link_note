import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';

final noteControllerProvider = StateNotifierProvider<NoteController, Set<Note>>(
  (ref) {
    return GetIt.I<NoteController>();
  },
);

class NoteController extends StateNotifier<Set<Note>> {
  NoteController(this._notesRepository) : super({});
  final NotesRepository _notesRepository;

  Future<void> addNote(Note note) async {
    try {
      await _notesRepository.create(note);
      state = {...state, note};
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<Set<Note>> fetchNotes() async {
    try {
      final notes = await _notesRepository.getAll();
      state = notes;
      return notes;
    } catch (e) {
      debugPrint(e.toString());
      return {};
    }
  }

  Stream fetchNotesRealTime()  {
      return _notesRepository.fetchNotesRealTime();
  }

  Future<void> updateNote(Note note) async {
    try {
      await _notesRepository.update(note);
      final copiedNotes = Set<Note>.from(state);
      copiedNotes.remove(note);
      copiedNotes.add(note);
      state = copiedNotes;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteNote(Note note) async {
    try {
      if (note.id == null) return;
      await _notesRepository.delete(note.id!);

      final updated = Set<Note>.from(state);
      updated.remove(note);

      state = updated;
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
