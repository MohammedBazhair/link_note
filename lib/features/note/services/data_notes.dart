import 'package:link_note/features/note/domain/entities/note.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotesService {
  final _instance = Supabase.instance.client;

  static const table = 'todo';

  Future<void> create(Note note) {
    return _instance.from(NotesService.table).insert(note.toMap());
  }

  Future<List<Note>> read() async {
    final mapList = await _instance.from(NotesService.table).select();

    final notes = mapList.map((m) => Note.fromMap(m)).toList();
    return notes;
  }

  Future<void> update() async {}
  Future<void> delete() async {}
}
