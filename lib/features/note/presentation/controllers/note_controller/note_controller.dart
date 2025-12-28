import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get_it/get_it.dart';
import '../../../../user/domain/repositories/user_repository.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/repositories/notes_repository.dart';

final noteControllerProvider =
    StateNotifierProvider<NoteController, Map<String, Note>>((ref) {
      return GetIt.I<NoteController>();
    });

class NoteController extends StateNotifier<Map<String, Note>> {
  NoteController(this._notesRepository, this._userRepository) : super({});
  final NotesRepository _notesRepository;
  final UserRepository _userRepository;
  final _notesStreamController = StreamController<List<Note>>.broadcast();

  String? get _userId => _userRepository.currentUser?.id;

  Stream<List<Note>> get notesStream => _notesStreamController.stream;

  StreamSubscription<List<Note>>? _subscription;

  Future<void> addNote(Note note) async {
    try {
      final userNote = note.copyWith(uuid: _userId);

      final createdNote = await _notesRepository.create(userNote);

      if (createdNote?.id == null) throw ArgumentError.notNull();

      final copiedMap = {...state};
      copiedMap[createdNote!.id!] = createdNote;
      state = copiedMap;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _setNotes(List<Note> notes) async {
    state = Map.fromEntries(notes.map((n) => MapEntry(n.id!, n)));
    await _subscription?.cancel();

    _notesStreamController.add(notes);
    await _notesRepository.insertNotes(notes);
  }

  Future<List<Note>> fetchNotes() async {
    try {
      final userId = _userRepository.currentUser?.id;

      final notes = await _notesRepository.getAll(userId);

      _setNotes(notes);
      return notes;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Note? getNoteById(String id) => state[id];

  void fetchNotesRealTime() {
    try {
      if (_userId == null) throw ArgumentError.notNull();
      _subscription?.cancel();
      _subscription = _notesRepository
          .fetchNotesRealTime(_userId!)
          .listen(
            _setNotes,
            onError: (e, stack) async {
              await fetchNotes();
            },
          );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Stream<Note?> fetchSingleNoteStream(String? noteId) {
    if (noteId == null) return Stream.value(null);
    return _notesRepository.fetchNoteStream(noteId);
  }

  Future<void> updateNote(Note note) async {
    try {
      await _notesRepository.update(note);
      final copiedMap = {...state};
      if (note.id == null) throw ArgumentError.notNull();
      copiedMap[note.id!] = note;
      state = copiedMap;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteNote(Note note) async {
    try {
      if (note.id == null) return;
      await _notesRepository.delete(note.id!);

      final updated = {...state};
      updated.remove(note.id);

      state = updated;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _notesStreamController.close();
    super.dispose();
  }
}
