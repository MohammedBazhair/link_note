import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';

final noteControllerProvider =
    StateNotifierProvider<NoteController, Map<String, Note>>((ref) {
      return GetIt.I<NoteController>();
    });

class NoteController extends StateNotifier<Map<String, Note>> {
  NoteController(this._notesRepository) : super({});
  final NotesRepository _notesRepository;
  final _notesStreamController = StreamController<List<Note>>.broadcast();

  Stream<List<Note>> get notesStream => _notesStreamController.stream;

  StreamSubscription<List<Note>>? _subscription;

  Future<void> addNote(Note note) async {
    try {
      final createdNote = await _notesRepository.create(note);
      if (createdNote?.id == null) throw ArgumentError.notNull();

      final copiedMap = {...state};
      copiedMap[createdNote!.id!] = createdNote;
      state = copiedMap;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<List<Note>> fetchNotes(String userId) async {
    try {
      final notes = await _notesRepository.getAll(userId);
      _notesStreamController.add(notes);

      state = Map.fromEntries(notes.map((n) => MapEntry(n.id!, n)));
      return notes;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Note? getNoteById(String id) => state[id];

  void fetchNotesRealTime(String userId) {
    try {
      _subscription?.cancel();
      _subscription = _notesRepository.fetchNotesRealTime(userId).listen((
        notes,
      ) {
        state = Map.fromEntries(notes.map((n) => MapEntry(n.id!, n)));
        _notesStreamController.add(notes);
      });
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
