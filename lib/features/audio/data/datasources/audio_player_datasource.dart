import 'package:audioplayers/audioplayers.dart';

import '../../../../core/constants/internal_constants/log.dart';

class AudioPlayerDatasource {
  AudioPlayerDatasource(this._player);

  final AudioPlayer _player;

  Future<void> playAsset(String assetPath) async {
    await _player.stop();
    await _player.play(AssetSource(assetPath));
  }

  Future<void> playFile(String path) async {
    await _player.stop();
    await _player.play(DeviceFileSource(path));
  }

  Future<Duration?> getAudioDuration(String path) async {
    try {
      await _player.setSourceDeviceFile(path);

      final duration = await _player.getDuration();
      Logger.log(message: 'Audio duration for $path: $duration');
      return duration;
    } finally {
      await _player.dispose();
    }
  }
}
