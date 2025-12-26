import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/external_constants/external_constants.dart';
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
      final now = DateTime.now();
      final newNote = note.copyWith(id: const Uuid().v4(), updatedAt: now);

      await _local.createNote(newNote);

      if (await _network.hasConnection()) await _remote.createNote(newNote);

      return newNote;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Note>> getAll(String? userId) async {
    final id =
        await _cache.getString(key: ExternalConsts.lastUserIdKey) ?? userId;
    final isOnline = await _network.hasConnection();
    final isFromRemote = id != null && isOnline;

    final localNotes = await _local.readNotes();
    if (!isFromRemote) return localNotes;

    final remoteNotes = await _remote.readNotes(id);

    final mapNotes = Map.fromEntries(
      remoteNotes.map((n) => MapEntry(n.id!, n)),
    );

    for (final note in localNotes) {
      mapNotes.update(note.id!, (n) {
        if (note.updatedAt.isBefore(n.updatedAt)) return n;

        update(note);
        return note;
      }, ifAbsent: () => note);
    }

    return mapNotes.values.toList();
  }

  @override
  Future<void> update(Note note) async {
    final updatedNote = note.copyWith(updatedAt: DateTime.now());
    if (await _network.hasConnection()) await _remote.updateNote(updatedNote);
    await _local.updateNote(updatedNote);
  }

  @override
  Future<void> delete(String id) async {
    if (await _network.hasConnection()) await _remote.deleteNote(id);

    await _local.deleteNote(id);
  }

  @override
  Stream<List<Note>> fetchNotesRealTime(String userId) {
    Stream<RowList> stream;
    try {
      stream = _remote.fetchNotesRealTime(userId);
    } catch (e) {
      stream = _local.fetchNotesRealTime();
    }

    return stream.map((raws) => List.from(raws.map(Note.fromMap)));
  }

  @override
  Stream<Note?> fetchNoteStream(String noteId) {
    return _remote.fetchNoteStream(noteId).map((m) {
      return m != null ? Note.fromMap(m) : null;
    });
  }

  @override
  Future<void> insertNotes(Iterable<Note> notes) async {
    try {
      if (!await _network.hasConnection()) throw const SocketException.closed();

      if (notes.elementAtOrNull(0)?.uuid != null) {
        return _remote.insertNotes(notes);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      await _local.insertNotes(notes);
    }
  }
}
