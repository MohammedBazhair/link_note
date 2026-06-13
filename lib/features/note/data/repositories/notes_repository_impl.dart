import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/constants/internal_constants/log.dart';
import '../../../../core/constants/internal_constants/typedef.dart';
import '../../../../core/features/database/local/cache_service_interface.dart';
import '../../../../core/features/network/connectivity_service.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_local_data_source.dart';
import '../datasources/notes_remote_data_source.dart';

class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl(this._remote, this._local, this._network, this._cache);
  final NotesRemoteDataSource _remote;
  final NotesLocalDataSource _local;
  final ConnectivityService _network;
  final SecureCacheService _cache;

  @override
  Future<Note?> create(Note note) async {
    try {
      final now = DateTime.now().toUtc();
      final userId =
          note.ownerId ??
          await _cache.getString(key: ExternalConsts.lastUserIdKey);

      final newNote = note.copyWith(
        id: note.id ?? const Uuid().v4(),
        updatedAt: now,
        ownerId: userId,
      );
      final hasConnection = await _network.hasConnection();
      await _local.createNote(note: newNote, skipLocalTracking: hasConnection);

      try {
        // ignore: unawaited_futures
        if (hasConnection) _remote.createNote(newNote);
      } catch (e, st) {
        Logger.log(error: e, stackTrace: st);
      }

      return newNote;
    } catch (e, st) {
      Logger.log(error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<List<Note>> getAll(String? userId) async {
    final ownerId =
        userId ?? await _cache.getString(key: ExternalConsts.lastUserIdKey);

    if (ownerId?.isEmpty ?? true) {
      return Future.value([]);
    }

    return _local.readNotes(ownerId: ownerId!, includeDeleted: false);
  }

  @override
  Future<void> update(Note note) async {
    final updatedNote = note.copyWith(updatedAt: DateTime.now().toUtc());
    final hasConnection = await _network.hasConnection();

    await _local.updateNote(
      note: updatedNote,
      skipLocalTracking: hasConnection,
    );
    if (hasConnection) unawaited(_remote.updateNote(updatedNote));
  }

  @override
  Future<void> delete(Note note) async {
    final noteId = note.id;
    if (noteId == null) return;

    final hasConnection = await _network.hasConnection();

    await _local.deleteNote(id: noteId, skipLocalTracking: hasConnection);

    if (hasConnection) unawaited(_remote.softDeleteNote(noteId));
  }

  Stream<List<Note>> _mapStreamToNotes(Stream<RowList> rawStream) {
    return rawStream
        .map(((raws) {
          final notes = raws
              .map(Note.fromMap)
              .where((note) => !note.isDeleted)
              .toList();
          notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return notes;
        }))
        .handleError((e, st) {});
  }

  @override
  Stream<List<Note>> fetchNotesRealTime(String? userId) async* {
    final ownerId =
        userId ?? await _cache.getString(key: ExternalConsts.lastUserIdKey);

    final hasOwnerId = ownerId?.isNotEmpty ?? false;

    final localStream = hasOwnerId
        ? _mapStreamToNotes(_local.fetchNotesRealTime(ownerId!))
        : Stream.value(<Note>[]);

    // If no user id provided, fallback to local stream only.
    if (!hasOwnerId) {
      yield* localStream;
      return;
    }

    final remoteStream = _mapStreamToNotes(
      _remote.fetchNotesRealTime(ownerId!),
    );

    final hasConnection = await _network.hasConnection();

    yield* (hasConnection ? remoteStream : localStream);
  }

  @override
  Stream<Note?> fetchNoteStream(String noteId) {
    return _remote
        .fetchNoteStream(noteId)
        .map((m) {
          return m != null ? Note.fromMap(m) : null;
        })
        .handleError((e) {});
  }

  @override
  Future<Note?> getNoteById(String noteId) {
    return _remote.getNoteById(noteId);
  }

  @override
  Future<void> deleteNotes(Set<String> notesIds) async {
    if (notesIds.isEmpty) return;

    final hasConnection = await _network.hasConnection();

    await _local.deleteNotes(ids: notesIds, skipLocalTracking: hasConnection);

    if (hasConnection) unawaited(_remote.softDeleteNotes(notesIds.toList()));
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    try {
      final ownerId = await _cache.getString(key: ExternalConsts.lastUserIdKey);

      return await _local.searchNotes(query: query, ownerId: ownerId);
    } catch (e,st) {
      Logger.log(error: e,stackTrace: st);
      return [];
    }
  }
}
