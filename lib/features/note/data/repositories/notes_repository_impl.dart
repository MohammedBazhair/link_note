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
  Future<Note?> create(Note note) async {
    try {
      final result = await _remote.createNote(note);

      return Note.fromMap(result);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Note>> getAll(String userId) => _remote.readNotes(userId);

  @override
  Future<void> update(Note note) => _remote.updateNote(note);

  @override
  Future<void> delete(String id) => _remote.deleteNote(id);

  @override
  Stream<List<Note>> fetchNotesRealTime(String userId) {
    final stream = _remote.fetchNotesRealTime(userId);
    return stream.map((raws) => List.from(raws.map(Note.fromMap)));
  }

  @override
  Stream<Note?> fetchNoteStream(String noteId) {
    return _remote.fetchNoteStream(noteId).map((m) {
      return m != null ? Note.fromMap(m) : null;
    });
  }
}
