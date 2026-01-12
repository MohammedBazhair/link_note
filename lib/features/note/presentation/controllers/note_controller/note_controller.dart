import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../../../user/domain/repositories/user_repository.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/repositories/notes_repository.dart';
import '../providers.dart';

final noteControllerProvider = NotifierProvider<NoteController, void>(() {
  return GetIt.I<NoteController>();
});

class NoteController extends Notifier<void> {
  NoteController(this._notesRepository, this._userRepository);

  final NotesRepository _notesRepository;
  final UserRepository _userRepository;
  final _notesStreamController = StreamController<List<Note>>.broadcast();

  String? get _userId => _userRepository.currentUser?.id;

  Future<void> addNote(Note note) async {
    final userNote = note.copyWith(uuid: _userId);

    await _notesRepository.create(userNote);
    _updateUi();
  }

  @override
  void build() {}

  Future<void> updateNote(Note note) async {
    await _notesRepository.update(note);
    _updateUi();
  }

  Future<void> deleteNote(Note note) async {
    if (note.id == null) return;
    await _notesRepository.delete(note.id!);
    _updateUi();
  }

  Future<Note?> getNoteById(String noteId) {
    return _notesRepository.getNoteById(noteId);
  }

  void _updateUi() {
    ref.invalidate(notesStreamProvider);
  }
}
