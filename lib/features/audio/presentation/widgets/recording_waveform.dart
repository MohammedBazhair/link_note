import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/audio_provider.dart';

class RecordingWaveform extends ConsumerWidget {
  const RecordingWaveform({super.key, required this.recorderController});

  final RecorderController recorderController;

  @override
  Widget build(BuildContext context, ref) {
    final isRecording = ref.watch(voiceRecordControllerProvider.select((s)=>s.isRecording));

    if (!isRecording) {
      return const Text('جاري الان بدء التسجيل');
    }

    return AudioWaveforms(
      recorderController: recorderController,
      size: const Size(double.infinity, 60),
      waveStyle: const WaveStyle(
        waveColor: Colors.blue,
        showMiddleLine: false,
        extendWaveform: true,
      ),
    );
  }
}
