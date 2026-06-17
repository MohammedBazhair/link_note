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
  String? get _userId => _userRepository.currentUser?.id;
  NotesRepository get _notesRepository => ref.read(notesRepositoryProvider);
  UserRepository get _userRepository => ref.read(userRepositoryProvider);

  @override
  Stream<List<Note>> build() {
    return _notesRepository.fetchNotesRealTime(_userId);
  }

  Future<void> _getAllNotes() async {
    final notes = await _notesRepository.getAll(_userId);

    state = AsyncData(notes);
  }

  Future<Note?> addNote(Note note) async {
    final userNote = note.copyWith(ownerId: _userId);

    final noteCreated = await _notesRepository.create(userNote);
    if (noteCreated == null) return null;

    unawaited(_getAllNotes());
    return noteCreated;
  }

  Future<void> updateNote(Note note) async {
    await _notesRepository.update(note);
    unawaited(_getAllNotes());

    if (note.id == null) return;
    final familyExists = ref.exists(getNoteByIdProvider(note.id!));

    if (familyExists) ref.invalidate(getNoteByIdProvider(note.id!));
  }

  Future<void> deleteNote(Note note) async {
    if (note.id == null) return;
    await _notesRepository.delete(note);
    await _getAllNotes();
  }

  Future<void> deleteNotes(Set<String> notesIds) async {
    await _notesRepository.deleteNotes(notesIds);
    await _getAllNotes();
  }

  Future<void> undoDeleteNotes(Set<String> notesIds) async {
    await _notesRepository.undoDeleteNotes(notesIds);
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

  void reset() {
    state = const AsyncData([]);
  }
}
