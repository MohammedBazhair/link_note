import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:link_note/features/note/domain/entities/note.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class NotesService {
  final _instance = Supabase.instance.client;

  static const _table = 'todo';
  static const _storageBucket = 'todo';

  Future<void> create(Note note) {
    return _instance.from(NotesService._table).insert(note.toMap());
  }

  Future<List<Note>> read() async {
    final mapList = await _instance.from(NotesService._table).select();

    final notes = mapList.map((m) => Note.fromMap(m)).toList();
    return notes;
  }

  Future<void> update(Note updatedNote) {
    if (updatedNote.id == null) return Future.value();
    return _instance
        .from(NotesService._table)
        .update(updatedNote.toMap())
        .eq('id', updatedNote.id!);
  }

  Future<void> delete(Note note) async {
    if (note.id == null) return Future.value();
    return _instance.from(NotesService._table).delete().eq('id', note.id!);
  }

  Future<String> uploadFile(String filePath) async {
    final random = Random().nextInt(100).toString();
    final filename = p.basename(filePath);
    final name = filename.split('.').first;
    final fileExtension = filename.split('.').last;
    final resultName = name + random + fileExtension;
    final file = File(filePath);
    final resultPath = 'public/$resultName';
    await _instance.storage
        .from(NotesService._storageBucket)
        .upload(resultPath, file);
    return resultPath;
  }

  String fileUrl(String path) {
    return _instance.storage.from(NotesService._storageBucket).getPublicUrl(path);
  }
}
