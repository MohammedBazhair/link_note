import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../user/domain/repositories/user_repository.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/repositories/notes_repository.dart';
import '../note_providers.dart';


class NoteController extends Notifier<void> {
  NoteController(this._notesRepository, this._userRepository);

  final NotesRepository _notesRepository;
  final UserRepository _userRepository;

  String? get _userId => _userRepository.currentUser?.id;

  @override
  void build() {}

  Future<void> addNote(Note note) async {
    final userNote = note.copyWith(uuid: _userId);

    await _notesRepository.create(userNote);
    _updateUi();
  }

  Future<void> updateNote(Note note) async {
    await _notesRepository.update(note);
    _updateUi();
  }

  Future<void> deleteNote(Note note) async {
    if (note.id == null) return;
    await _notesRepository.delete(note);
    _updateUi();
  }

  Stream<List<Note>> fetchNotesRealtime() {
  return  _notesRepository.fetchNotesRealTime(_userId);
  }

  Stream<Note?> fetchSingleNoteRealtime(String noteId) {
  return  _notesRepository.fetchNoteStream(noteId);
  }

  Future<Note?> getNoteById(String noteId) {
    return _notesRepository.getNoteById(noteId);
  }

  Future<void> syncNotes() async {
    await _notesRepository.syncNotes(_userId);
  }

  void _updateUi() {
    ref.invalidate(notesStreamProvider);
  }
}
