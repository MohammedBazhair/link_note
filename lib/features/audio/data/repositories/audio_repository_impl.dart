import '../../domain/repositories/audio_repository.dart';
import '../datasources/audio_player_datasource.dart';

class AudioRepositoryImpl implements AudioRepository {
  AudioRepositoryImpl(this.datasource);
  final AudioPlayerDatasource datasource;

  @override
  Future<void> play(String assetPath) {
    return datasource.play(assetPath);
  }
}
