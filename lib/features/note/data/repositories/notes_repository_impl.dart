// ignore_for_file: unawaited_futures

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/constants/internal_constants/log.dart';
import '../../../../core/constants/internal_constants/typedef.dart';
import '../../../../core/features/database/local/cache_service.dart';
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
  final LocalCacheService _cache;

  @override
  Future<Note?> create(Note note) async {
    try {
      final now = DateTime.now().toUtc();
      final userId =
          note.ownerId ?? _cache.getString(key: ExternalConsts.lastUserIdKey);

      final newNote = note.copyWith(
        id: note.id ?? const Uuid().v4(),
        updatedAt: now,
        ownerId: userId,
      );
      final hasConnection = await _network.hasConnection();
      await _local.createNote(note: newNote, skipLocalTracking: hasConnection);

      try {
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
  Future<List<Note>> getAll() => _local.readNotes(includeDeleted: false);

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
    final localStream = _mapStreamToNotes(_local.fetchNotesRealTime());

    // If no user id provided, fallback to local stream only.
    if (userId == null || userId.isEmpty) {
      yield* localStream;
      return;
    }

    final remoteStream = _mapStreamToNotes(_remote.fetchNotesRealTime(userId));

    // Safely check network availability. If the connectivity check fails
    // for any reason, fall back to the local stream instead of throwing.
    bool hasConnection = false;
    try {
      hasConnection = await _network.hasConnection();
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
      hasConnection = false;
    }

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
}
