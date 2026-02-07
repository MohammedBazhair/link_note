import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';

import '../../data/datasources/audio_player_datasource.dart';
import '../../data/datasources/voice_record_datasource.dart';
import '../../data/repositories/audio_repository_impl.dart';
import '../../data/repositories/voice_record_repository_impl.dart';
import 'audio_controller.dart';
import 'voice_record_controller.dart';
import 'voice_record_state.dart';

final audioProvider = Provider((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
});

final audioDatasourceProvider = Provider((ref) {
  final player = ref.read(audioProvider);
  return AudioPlayerDatasource(player);
});

final audioRepositoryProvider = Provider((ref) {
  final datasource = ref.read(audioDatasourceProvider);
  return AudioRepositoryImpl(datasource);
});

final audioControllerProvider = NotifierProvider<AudioController, void>(
  AudioController.new,
);

final _voiceRecordProvider = Provider((ref) => AudioRecorder());

final _voiceRecordDataSourceProvider = Provider((ref) {
  final recorder = ref.read(_voiceRecordProvider);
  return VoiceRecordDataSource(recorder);
});

final voiceRecordRepositoryProvider = Provider((ref) {
  final source = ref.read(_voiceRecordDataSourceProvider);

  return VoiceRecordRepositoryImpl(source);
});

final voiceRecordControllerProvider =
    NotifierProvider<VoiceRecordController, VoiceRecordState>(() {
      return VoiceRecordController();
    });

final getAudioDurationProfider = FutureProvider.family
    .autoDispose<Duration, String?>((ref, audioPath) {
      final controller = ref.read(audioControllerProvider.notifier);
      return controller.getSoundDuration(audioPath);
    });
