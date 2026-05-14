class VoiceRecordState {
  VoiceRecordState({
    this.isRecording = false,
    this.path,
    this.duration = Duration.zero,
  });

  final String? path;
  final Duration duration;
  final bool isRecording;

  VoiceRecordState copyWith({
    String? path,
    Duration? duration,
    bool? isRecording,
  }) {
    return VoiceRecordState(
      path: path ?? this.path,
      duration: duration ?? this.duration,
      isRecording: isRecording ?? this.isRecording,
    );
  }
}
