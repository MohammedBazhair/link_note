import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/constants/internal_constants/typedef.dart';
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

  void setNotes(Set<Note> notes) {
    state = notes;
  }

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

  Note? getNoteById(String? id) {
    try {
      return state.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  Stream fetchNotesRealTime(String userId) {
    try {
      (_notesRepository.fetchNotesRealTime(userId) as Stream<RowList>).listen((
        notes,
      ) {
        state = notes.map(Note.fromMap).toSet();
      });

      return _notesRepository.fetchNotesRealTime(userId);
    } catch (e) {
      debugPrint(e.toString());
      return const Stream.empty();
    }
  }

  Stream<Note?> fetchNoteStream(String noteId) {
    return _notesRepository.fetchNoteStream(noteId);
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
