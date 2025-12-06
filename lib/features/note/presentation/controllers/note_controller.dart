import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get_it/get_it.dart';
import 'package:link_note/features/note/domain/entities/note.dart';
import 'package:link_note/features/note/domain/repositories/notes_repository.dart';

final noteControllerProvider = StateNotifierProvider<NoteController, Set<Note>>(
  (ref) {
    return GetIt.I<NoteController>();
  },
);

class NoteController extends StateNotifier<Set<Note>> {
  final NotesRepository _notesRepository;
  NoteController(this._notesRepository) : super({});

  Future<void> addNote(Note note) async {
    try {
      await _notesRepository.create(note);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> readAllNotes() async {
    try {
      final notes = await _notesRepository.getAll();
      state = notes;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      await _notesRepository.update(note);
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
