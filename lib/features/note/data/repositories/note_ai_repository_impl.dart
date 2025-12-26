import '../../domain/entities/ai_response.dart';
import '../../domain/repositories/note_ai_repository.dart';
import '../datasources/note_ai_remote_datasource.dart';

class NoteAiRepositoryImpl implements NoteAiRepository {
  NoteAiRepositoryImpl(this._remote);
  final NoteAiRemoteDataSource _remote;

  @override
  Future<AiResponseEntity> improveNote(String note) async {
    final improved = await _remote.improveNote(note);
    return improved;
  }
}
