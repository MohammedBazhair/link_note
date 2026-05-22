import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/internal_constants/log.dart';
import '../../../../../core/presentation/providers/core_providers.dart';
import '../../../../user/domain/repositories/user_repository.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/repositories/notes_repository.dart';
import '../../../injection.dart';
import '../note_providers.dart';

class NoteController extends StreamNotifier<List<Note>> {
  late final NotesRepository _notesRepository;
  late final UserRepository _userRepository;

  String? get _userId => _userRepository.currentUser?.id;

  @override
  Stream<List<Note>> build() {
    _notesRepository = ref.read(notesRepositoryProvider);
    _userRepository = ref.read(userRepositoryProvider);
    return _notesRepository.fetchNotesRealTime(_userId);
  }

  Future<void> _getAllNotes() async {
    final notes = await _notesRepository.getAll(_userId);
    state = AsyncData(notes);
  }

  Future<void> addNote(Note note) async {
    final userNote = note.copyWith(ownerId: _userId);

    final noteCreated = await _notesRepository.create(userNote);
    if (noteCreated == null) return;

    await _getAllNotes();
  }

  Future<void> updateNote(Note note) async {
    try {
      await _notesRepository.update(note);
      await _getAllNotes();
    } catch (e, st) {
      Logger.log(error: e, stackTrace: st);
    }
  }

  Future<void> deleteNote(Note note) async {
      if (note.id == null) return;
      await _notesRepository.delete(note);
      await _getAllNotes();
   
  }

  Stream<Note?> fetchSingleNoteRealtime(String noteId) {
    return _notesRepository.fetchNoteStream(noteId);
  }

  Future<Note?> getNoteById(String noteId) {
    return _notesRepository.getNoteById(noteId);
  }

  Future<void> syncNotes() async {
    try {
      await ref.read(syncNotesControllerProvider.notifier).syncNotes();
    } catch (e, st) {
      Logger.log(error: e, stackTrace: st);
    }
    await _getAllNotes();
  }
}
