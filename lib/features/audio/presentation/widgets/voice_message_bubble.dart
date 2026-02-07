import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

class VoiceMessageBubble extends StatefulWidget {
  const VoiceMessageBubble({super.key, required this.path});

  final String path;

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  final PlayerController _playerController = PlayerController();

  @override
  void initState() {
    super.initState();
    _playerController;

    _playerController.preparePlayer(path: widget.path);
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () async {
            await _playerController.startPlayer();
          },
        ),
        AudioFileWaveforms(
          size: const Size(150, 40),
          playerController: _playerController,
          playerWaveStyle: const PlayerWaveStyle(
            fixedWaveColor: Colors.grey,
            liveWaveColor: Colors.blue,
            spacing: 6,
          ),
        ),
      ],
    );
  }
}
