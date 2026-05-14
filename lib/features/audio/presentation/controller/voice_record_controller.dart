import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/internal_constants/log.dart';
import '../../../../core/errors/exceptions.dart';
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

  Future<bool> startRecording() async {
    try {
      if (!await _repo.hasPermissions()) {
        Logger.log(message: 'No permissions');
        throw const PermissionsException('No permissions');
      }
      Logger.log(message: 'has permissions');

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
      return true;
    } on PermissionsException catch (_) {
      return false;
    } catch (e) {
      _recordTimer?.cancel();
      Logger.log(error: e);
      return false;
    }
  }

  Future<void> stopRecording() async {
    try {
      _recordTimer?.cancel();

      final outputPath = await _repo.stopRecording();

      state = state.copyWith(
        isRecording: false,
        path: outputPath ?? state.path,
        duration: Duration.zero,
      );
    } catch (e) {
      Logger.log(error: e);
    }
  }
}
