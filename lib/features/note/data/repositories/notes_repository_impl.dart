import 'package:link_note/core/features/database/local/cache_service.dart';
import 'package:link_note/core/features/network/network_service.dart';
import 'package:link_note/features/note/data/datasources/notes_remote_data_source.dart';
import 'package:link_note/features/note/domain/entities/note.dart';
import 'package:link_note/features/note/domain/repositories/notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesRemoteDataSource _remote;
  final LocalCacheService _localCache;
  final NetworkService _network;

  NotesRepositoryImpl(this._remote, this._localCache, this._network);

  @override
  Future<void> create(Note note) => _remote.createNote(note);

  @override
  Future<Set<Note>> getAll() => _remote.readNotes();

  @override
  Future<void> update(Note note) => _remote.updateNote(note);

  @override
  Future<void> delete(String id) => _remote.deleteNote(id);
}
