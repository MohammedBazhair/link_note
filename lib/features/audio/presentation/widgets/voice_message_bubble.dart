import 'dart:typed_data';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../offline_chat/presentation/widgets/common/user_avatar_with_status.dart';

class VoiceMessageBubble extends StatefulWidget {
  const VoiceMessageBubble({
    super.key,
    required this.path,
    required this.image,
    required this.time,
  });

  final String path;
  final Uint8List? image;
  final DateTime time;

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  final PlayerController _playerController = PlayerController();

  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _playerController;

    _preparePlayer();
  }

  Future<void> _preparePlayer() async {
    await _playerController.preparePlayer(path: widget.path);
    await _playerController.setFinishMode(finishMode: FinishMode.pause);
    final milliseconds = _playerController.maxDuration;

    setState(() {
      _duration = Duration(milliseconds: milliseconds);
    });
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final whatsappPlayerWaveStyle = PlayerWaveStyle(
      fixedWaveColor: Colors.grey.shade500,
      liveWaveColor: const Color(0xFFF0FBFF),
      waveThickness: 2.2,
      spacing: 4.0,
      showTop: false,
      waveCap: StrokeCap.square,
      seekLineThickness: 5,
      backgroundColor: Colors.transparent,
      seekLineColor: Colors.red,
      scaleFactor: 90.0,

      showBottom: false,
    );

    return Row(
      textDirection: TextDirection.ltr,
      mainAxisSize: MainAxisSize.min,
      children: [
        AvatarBytesWidget(image: widget.image, radius: 20, icon: Icons.mic),
        StreamBuilder(
          stream: _playerController.onPlayerStateChanged,
          builder: (context, asyncSnapshot) {
            final playerState = asyncSnapshot.data ?? PlayerState.stopped;
            final isPlaying = playerState == PlayerState.playing;

            return IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              color: Colors.white,
              onPressed: () {
                isPlaying
                    ? _playerController.pausePlayer()
                    : _playerController.startPlayer(forceRefresh: false);
              },
            );
          },
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AudioFileWaveforms(
                size: const Size(90, 30),
                playerController: _playerController,
                playerWaveStyle: whatsappPlayerWaveStyle,
                waveformType: WaveformType.fitWidth,
              ),
              DefaultTextStyle.merge(
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
                child: Row(
                  textDirection: TextDirection.ltr,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreamBuilder(
                      stream: _playerController.onCurrentDurationChanged,
                      builder: (context, snapshot) {
                        final isPlaying =
                            _playerController.playerState ==
                            PlayerState.playing;

                        if (snapshot.hasData) {
                          final position = Duration(
                            milliseconds: snapshot.data!,
                          );
                          return Text(
                            isPlaying ? position.toMMSS : _duration.toMMSS,
                          );
                        }
                        return Text(_duration.toMMSS);
                      },
                    ),
                    Text(
                      widget.time.formattedChatTime,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(letterSpacing: -0.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
