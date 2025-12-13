import '../../../../core/features/database/local/cache_service.dart';
import '../../../../core/features/network/network_service.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_remote_data_source.dart';

class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl(this._remote, this._localCache, this._network);
  final NotesRemoteDataSource _remote;
  final LocalCacheService _localCache;
  final NetworkService _network;

  @override
  Future<void> create(Note note) => _remote.createNote(note);

  @override
  Future<Set<Note>> getAll() => _remote.readNotes();

  @override
  Future<void> update(Note note) => _remote.updateNote(note);

  @override
  Future<void> delete(String id) => _remote.deleteNote(id);

  @override
  Stream fetchNotesRealTime(String userId) =>
      _remote.fetchNotesRealTime(userId);

  @override
  Stream<Note?> fetchNoteStream(String noteId) {
    return _remote.fetchNoteStream(noteId).map((m) {
      return m != null ? Note.fromMap(m) : null;
    });
  }
}
