import 'package:audioplayers/audioplayers.dart';

class AudioPlayerDatasource {
  AudioPlayerDatasource(this._player);

  final AudioPlayer _player;

  Future<void> play(String assetPath) async {
    await _player.stop();
    await _player.play(AssetSource(assetPath));
  }
}
