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
  Future<List<Note>> getAll() {
    return _local.readNotes();
  }

  @override
  Future<void> update(Note note, {bool changeUpdateDate = true}) async {
    final updatedNote = changeUpdateDate
        ? note.copyWith(updatedAt: DateTime.now())
        : note;
    if (await _network.hasConnection()) await _remote.updateNote(updatedNote);
    await _local.updateNote(updatedNote);
  }

  @override
  Future<void> delete(Note note) async {
    final noteId = note.id;
    if (noteId == null) return;

    if (await _network.hasConnection()) {
      await _remote.deleteNote(noteId);
      await _local.deleteNote(noteId);
    } else {
      await _local.updateNote(note.copyWith(deletedAt: DateTime.now()));
    }
  }

  Stream<List<Note>> _mapStreamToNotes(Stream<RowList> rawStream) {
    return rawStream
        .map(((raws) {
          final notes = raws
              .map(Note.fromMap)
              .where((note) => note.deletedAt == null)
              .toList();
          notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return notes;
        }))
        .handleError((_) {});
  }

  @override
  Stream<List<Note>> fetchNotesRealTime(String? userId) async* {
    if (userId?.isEmpty ?? true) {
      yield* _mapStreamToNotes(_local.fetchNotesRealTime());
      return;
    }

    try {
      final isConnected = await _network.hasConnection();

      final stream = isConnected
          ? _remote.fetchNotesRealTime(userId!)
          : _local.fetchNotesRealTime();

      await for (final notes in _mapStreamToNotes(stream)) {
        print('Stream sending...');
        // insertNotes(notes);

        yield notes;
      }
    } catch (e) {
      debugPrint('Error in fetchNotesRealTime: $e');
    }
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
      print('Saved Sucssufelly in Local Cache');
    }
  }

  @override
  Future<Note?> getNoteById(String noteId) {
    return _remote.getNoteById(noteId);
  }

  @override
  Future<void> syncNotes(String? userId) async {
    final id =
        await _cache.getString(key: ExternalConsts.lastUserIdKey) ?? userId;
    if (id == null) return;
    if (!await _network.hasConnection()) return;

    final localNotes = await _local.readNotes();
    final remoteNotes = await _remote.readNotes(id);

    final remoteNotesMap = Map.fromEntries(
      remoteNotes.map((n) => MapEntry(n.id!, n)),
    );

    for (final localNote in localNotes) {
      final remoteNote = remoteNotesMap[localNote.id];

      if (remoteNote != null && localNote.isDeleted) {
        await delete(localNote);
        continue;
      }

      if (remoteNote == null) {
        await create(localNote);
        continue;
      }

      if (localNote.updatedAt.isAfter(remoteNote.updatedAt)) {
        await update(localNote, changeUpdateDate: false);
      } else if (remoteNote.updatedAt.isAfter(localNote.updatedAt)) {
        await update(remoteNote, changeUpdateDate: false);
      }
    }
  }
}
