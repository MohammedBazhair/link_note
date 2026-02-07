import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/internal_constants/log.dart';
import '../../domain/repositories/voice_record_repository.dart';
import 'audio_provider.dart';
import 'voice_record_state.dart';

class VoiceRecordController extends Notifier<VoiceRecordState> {
  late final VoiceRecordRepository _repo;
  Timer? _recordTimer;

  @override
  VoiceRecordState build() {
    _repo = ref.read(voiceRecordRepositoryProvider);

    return VoiceRecordState();
  }

  Future<void> startRecording() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final now = DateTime.now();

      final fileName =
          'voice_${now.year}${now.month}${now.day}_'
          '${now.hour}${now.minute}${now.second}.ogg';

      final filePath = join(dir.path, fileName);

      await _repo.startRecording(path: filePath);

      if (_recordTimer?.isActive ?? false) _recordTimer?.cancel();

      state = state.copyWith(isRecording: true, path: filePath);

      _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final duration = state.duration;
        final newDuration = Duration(seconds: duration.inSeconds + 1);

        state = state.copyWith(duration: newDuration);
      });
    } catch (e) {
      _recordTimer?.cancel();
      Logger.log(error: e);
    }
  }

  Future<void> stopRecording() async {
    try {
      _recordTimer?.cancel();

      await _repo.stopRecording();
    } catch (e) {
      Logger.log(error: e);
    }
  }
}
