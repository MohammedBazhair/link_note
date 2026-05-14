import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

class RecordingWaveform extends StatelessWidget {
  const RecordingWaveform({super.key, required this.recorderController});

  final RecorderController recorderController;

  @override
  Widget build(BuildContext context) {
    const whatsappWaveStyle = WaveStyle(
      waveColor: Color(0xFF2579D3), 
      waveThickness: 2.2,
      spacing: 4.0,

      showMiddleLine: false,

      extendWaveform: true,

      backgroundColor: Colors.transparent,

      scaleFactor: 18.0,
    );

    return AudioWaveforms(
      recorderController: recorderController,
      size: const Size(double.infinity, 47),
      waveStyle: whatsappWaveStyle,
    );
  }
}
